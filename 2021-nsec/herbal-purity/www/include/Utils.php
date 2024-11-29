<?php

class Utils {
  public static function param(string $name) {
    if(isset($_GET[$name])) {
      return $_GET[$name];
    } else if(isset($_POST[$name])) {
      return $_POST[$name];
    }
  }

  public static function include_file(string $file) {
    if(Utils::validate_pattern($file, '\.php$')) {
      include $file;
    } else {
      echo 'Cannot include file';
    }
  }

  public static function validate_pattern($string, $pattern, $f='m') {
    return preg_match('/'.$pattern.'/'.$f,$string) === 1;
  }
}
