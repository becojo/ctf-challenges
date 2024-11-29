<?php

class Form {
  public function __construct(Model $model, array $object = null) {
    $this->model = $model;
    $this->object = $object;
  }

  public function render() {
    if(!empty($this->object)) {
      $this->field("ID", function() {
        echo $this->object['id'];

        $this->type_hidden('id');
      });
    }

    foreach($this->model->fields as $name => $type) {
      $this->field($name, function() use($type, $name) {
        $this->{"type_$type"}($name);
      });
    }
  }

  public function field($name, $cb) {
    echo '<p class="field">';
    echo '<label>';
    echo '<span>';
    echo e($name);
    echo '</span>';

    $cb();

    echo '</label>';
    echo '</p>';
  }

  public function value($name) {
    if(empty($this->object)) return;

    echo e($this->object[$name]);
  }

  public function type_int($name) {
    echo '<input name="' . e($name) . '" type="number" value="';
    $this->value($name);
    echo '">';
  }

  public function type_string($name) {
    echo '<input name="' . e($name) . '" value="';
    $this->value($name);
    echo '">';
  }

  public function type_hidden($name) {
    echo '<input name="'. e($name) . '" type="hidden" value="';
    $this->value($name);
    echo '">';
  }
}
