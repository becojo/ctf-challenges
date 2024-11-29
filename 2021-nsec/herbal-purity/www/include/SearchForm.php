<?php

class SearchForm {
  public $model;

  public function __construct(Model $model) {
    $this->model = $model;
  }

  public function render() {
    echo '<p>';
    echo '<form>';
    echo '<select onchange="this.form.elements[1].name=`search[${this.value}]`">';

    foreach($this->searchableFields() as $field) {
      echo '<option>';
      echo e($field);
      echo '</option>';
    }

    echo '</select>';

    echo '<input name="search['.$this->searchableFields()[0].']" placeholder="Search...">';

    echo '<input type="submit">';
    echo '</form>';
    echo '</p>';
  }

  public function searchableFields() {
    $keys = array_keys($this->model->fields);

    $keys[] = 'id';

    return $keys;
  }
}
