<?php

class Token {
  public static function parse(string $token) {
    $parts = explode(".", $token);
    if(count($parts) != 2) {
      return false;
    }

    list($claims, $signature) = $parts;

    $real_signature = hash_hmac("sha1", "v1.$claims", self::secret());

    if($real_signature != $signature) {
      return false;
    }

    return json_decode(base64url_decode($claims)^str_repeat("X", strlen($claims)));
  }

  public static function sign($claims) {
    $claims = json_encode($claims);
    $claims = $claims^str_repeat("X", strlen($claims));
    $claims = base64url_encode($claims);
    $signature = hash_hmac("sha1", "v1.$claims", self::secret());
    return "$claims.$signature";
  }

  public static function secret() {
    return file_get_contents("/secret");
  }
}

if(Utils::param('debug')) {
  $t = new Token;

  $token = $t->sign(['user_id' => Utils::param('id'), 'iat' => time()]);

  var_dump($token);
}
