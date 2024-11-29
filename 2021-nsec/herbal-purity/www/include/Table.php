<?php

class Table {
  public function __construct($model) {
    $this->model = $model;
  }

  public function render() {
    $rows = $this->search();
    $cols = [];
    $values = [];
    $first_row = true;

    foreach($rows as $row) {
      $row_values = [];

      foreach($row as $key => $value) {
        if($first_row) {
          $cols[] = $key;
        }

        $row_values[] = $value;
      }

      $values[] = $row_values;
      $first_row = false;
    }

    echo '<table border=1>';
    echo '<thead>';
    foreach($cols as $col) {
      echo '<th>';
      echo e($col);
      echo '</th>';
    }
    echo '</thead>';
    echo '<tbody>';

    foreach($values as $row) {
      echo '<tr>';

      foreach($row as $value) {
        echo '<td>';
        echo e($value);
        echo '</td>';
      }

      echo '<td><a href="edit_';
      echo $this->model->table;
      echo '.php?id=';
      echo e($row[0]);
      echo '">Edit</a>';
      echo $this->model->extraAction($row);
      echo '</td>';
      echo '<tr>';
    }

    echo '</tbody>';
    echo '</table>';

  }

  public function search() {
    if(Utils::param('search')) {
      $search = new Search(Utils::param('search'), $this->model);
      return $search->fetchAll();
    }
    
    return $this->model->fetchAll();
  }
}
