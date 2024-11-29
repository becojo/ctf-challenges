<?php

class LoginPage extends Page {
  public function setup() {
    $this->nav = false;

    if(isset($_COOKIE['token'])) {
      $token = Token::parse($_COOKIE['token']);
      if(isset($token->user_id)) {
        $_SESSION['user_id'] = $token->user_id;
        setcookie('token', null, -1, '/');
      }
    }
    $logged_in = false;

    if(isset($_SESSION['user_id'])) {
      $logged_in = true;
    }

    if($this->isLogin()) {
      $user = $this->findUser();

      if($user) {
        $_SESSION['user_id'] = $user['id'];

        if($user['name'] == 'admin') {
          $_SESSION['admin_user_id'] = $user['id'];
        }

        $logged_in = true;
      } else {
        $this->flash->info('fail');
      }
    }

    if($logged_in) {
      $this->flash->info('Welcome! ' . file_get_contents("/motd"));
      $this->redirect('index.php');
    }
  }

  public function isLogin() {
    return Utils::param('action') == 'login';
  }

  public function requireLogin() {
    return false;
  }

  public function findUser() {
    $users = $this->model->fetchAll();

    foreach($users as $user) {
      if(str_starts_with($user['password_hash'], 'FLAG-')) {
        $user['password_hash'] = sha1($user['password_hash']);
      }

      if($user['name'] == Utils::param('username') && $user['password_hash'] === sha1(Utils::param('password'))) {
        return $user;
      }
    }

    return false;
  }
}
