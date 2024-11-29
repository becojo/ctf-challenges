<?php

class Search {
  public function __construct(array $query, Model $model) {
    $this->model = $model;
    $this->query = $query;
  }

  public function fetchAll() {
    $sql = [];

    foreach($this->query as $field => $value) {
      $sql[] = "(`$field` LIKE '%' || :$field || '%')";
    }

    $sql = "select * from {$this->model->table} where " . implode(" OR ", $sql);

    $stmt = $this->model->connection()->prepare($sql);

    foreach($this->query as $field => $value) {
      $stmt->bindValue(":$field", $value);
    }

    $rows = [];

    $results = $stmt->execute();
    while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
      $rows[] = $row;
    }

    return $rows;
  }
}
