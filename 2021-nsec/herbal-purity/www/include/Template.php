<?php

class Template {
  public string $file;
  public array $tokens;
  public $scope;

  public function __construct(string $name, $scope) {
    $this->file = "include/templates/$name.template";
    $this->tokens = [];
    $this->scope = $scope;

    $this->parse();
  }

  public function parse() {
    $template = file_get_contents($this->file);
    $offset = 0;

    while(($index = strpos($template, "{{", $offset)) !== false) {
      $this->tokens[] = substr($template, $offset, $index - $offset);
      $end_pos = strpos($template, "}}", $index);
      $content = trim(substr($template, $index + 2, $end_pos - $index - 2));

      if($content[0] == '$') {
        $this->tokens[] = [ '$var' => substr($content, 1) ];
      }

      $offset = $end_pos + 2;
    }

    if($offset == 0 && $index == false) {
      $this->tokens[] = $template;
    } else {
      if($offset < strlen($template)) {
        $this->tokens[] = substr($template, $offset);
      }
    }
  }

  public function render() {
    foreach($this->tokens as $token) {
      if(isset($token['$var'])) {
        $var = $this->scope->{$token['$var']};

        if(is_string($var)) {
          $token = $var;
        }

        if(isset($var['$obj']) && isset($var['$method']) && is_object($var['$obj']) && is_string($var['$method'])) {
          $var['$obj']->{$var['$method']}();
          continue;
        }

        if(isset($var['$func'])) {
          $args = isset($var['$args']) ? $var['$args'] : [];

          if($var['$func'] instanceof Closure) {
            call_user_func($var['$func']);
          } else {
            call_user_func(['Utils', $var['$func']], $args);
          }
          continue;
        }
      }

      if(is_string($token)) {
        echo $token;
      }
    }
  }

  public function partial(): array {
    return [
      '$obj' => $this,
      '$method' => 'render'
    ];
  }
}
