<?php

class Page {
  public Template $t;
  public Template $layout;
  public array $variables;
  public string $title;

  public function __construct() {
    $this->variables = [];
    $this->layout = $this->newTemplate("layout");
    $this->nav = $this->newTemplate("nav")->partial();
    $this->flash = new Flash();
  }

  public function setup() {}

  public function run() {
    $this->requireLogin();
    $this->doLogout();

    $this->setup();

    $this->body = $this->t->partial();
    $this->renderFlash = $this->renderObject($this->flash);
    $this->v = $this->lambda(function() { echo time(); });

    $this->layout->render();
  }

  public function newTemplate(string $name) {
    return new Template($name, $this);
  }

  public function renderObject($obj) {
    return ['$obj' => $obj, '$method' => 'render'];
  }

  public function lambda($cb) {
    return ['$func' => $cb];
  }

  public function handleNotFound($object) {
    if(empty($object)) {
      die("Not found");
    }
  }

  public function redirect($url) {
    header("Location: $url");
    die;
  }

  public function requireLogin() {
    $redirect = false;

    if(isset($_SESSION['user_id']) && empty((new Healers)->get($_SESSION['user_id']))) {
      $_SESSION['user_id'] = null;
    }

    if($this->admin === true) {
      if(!isset($_SESSION['user_id']) || !isset($_SESSION['admin_user_id']) || $_SESSION['user_id'] != $_SESSION['admin_user_id']) {
        $this->flash->info('Access denied: only admin can access this page');
        return $this->redirect('index.php');
      }
    }

    if(empty($_SESSION['user_id'])) {
      $this->flash->info('Please log in');
      $this->redirect('login.php');
    }
  }

  public function doLogout() {
    if(Utils::param('action') == 'logout') {
      session_destroy();
      $this->redirect('login.php');
    }
  }

  public function __get(string $key) {
    if(isset($this->variables["$key"])) {
      return $this->variables["$key"];
    }

    return "(undefined $key)";
  }

  public function __set(string $key, $value) {
    $this->variables["$key"] = $value;
  }
}
