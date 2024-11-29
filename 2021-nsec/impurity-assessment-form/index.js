var express = require('express');
var { graphqlHTTP } = require('express-graphql');
var { buildSchema } = require('graphql');
var wkhtmltopdf = require('wkhtmltopdf');
var LRU = require('lru-cache');
var fs = require('fs').promises;
var http = require('http');
var crypto = require('crypto');
var cookieParser = require('cookie-parser');

var port = 20129;
var secret = crypto.randomBytes(32).toString('hex');
var app = express();
var db = new LRU({ maxSize: 10 });
var flag = 'FLAG-ef50b98b53a70405cf861c8f239f6d7b';

var schema = buildSchema(`
  interface Cacheable {
    etag: String!
  }

  type Treatment implements Cacheable {
    id: String!
    healer: String
    patient: String
    description: String
    etag: String!
  }

  type Query {
    flag: String
    treatment(id: String!): Treatment
  }

  input TreatmentInput {
    healer: String
    patient: String
    description: String
  }

  type Mutation {
    treatmentCreate(input: TreatmentInput): Treatment
  }
`);

var root = {
  flag: (args, request) => {
    if(request.cookies['auth'] == secret) {
      return flag;
    } else {
      return 'Access denied';
    }
  },

  treatment: (args) => {
    return db.get(`treatments:${args.id}`);
  },

  treatmentCreate: (args) => {
    var treatment = args.input;
    treatment.id = Math.random().toString().slice(2);
    treatment.etag = Math.random().toString().slice(2);

    db.set(`treatments:${treatment.id}`, treatment);

    return treatment;
  }
};

app.use(express.static('public'));
app.use(cookieParser());

app.use('/graphql', graphqlHTTP({
  schema: schema,
  rootValue: root,
  graphiql: true,
}));

async function render() {
  var body = await fs.readFile("views/render.html", "binary");
  return Buffer.from(body);
}

app.use('/render.html', (req, res) => {
  if(req.headers.auth == secret) {
    res.cookie('auth', secret);
  }

  render().then(body => res.end(body));
});

app.get('/render.pdf', (req, res) => {
  var path = req.originalUrl.replace('/render.pdf', '/render.html');

  wkhtmltopdf(`http://127.0.0.1:${port}${path}`, {
    javascriptDelay: 1000,
    loadMediaErrorHandling: 'ignore',
    loadErrorHandling: 'ignore',
    printMediaType: true,
    marginTop: 0,
    marginLeft: 0,
    marginRight: 0,
    marginBottom: 0,
    customHeader: [
      ['Auth', secret],
    ]
  }, (err, _) => { console.log(err); }).pipe(res);
});

app.get('/', (req, res) => {
  res.sendFile('public/index.html');
});

app.listen(port, '0.0.0.0');
