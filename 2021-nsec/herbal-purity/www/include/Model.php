<?php

class Model {
  private static ?SQLite3 $instance = null;

  public static function connection() {
    if(self::$instance == null) {
      self::$instance = new SQLite3('../db.sqlite3');
    }

    return self::$instance;
  }

  public function __construct() {}

  public function get(int $id) {
    $query = $this->connection()->query("select * from {$this->table} where id = {$id} limit 1");

    return $query->fetchArray(SQLITE3_ASSOC);
  }

  public function update(int $id, array $fields) {
    foreach($fields as $key => $value) {
      $updates[] = "$key = :$key";
    }

    $updates = implode(", ", $updates);
    $query = "update {$this->table} set {$updates} where id = :id";
    $stmt = $this->connection()->prepare($query);

    if(!$stmt) { return false; }

    $stmt->bindValue("id", $id);

    foreach($fields as $key => $value) {
      $stmt->bindValue($key, $value);
    }

    return $stmt->execute()->finalize();
  }

  public function fetchAll() {
    $query = $this->connection()->query("select * from {$this->table}");
    $rows = [];

    while ($row = $query->fetchArray(SQLITE3_ASSOC)) {
      $rows[] = $row;
    }

    return $rows;
  }

  public function insert(array $values) {
    foreach($values as $key => $value) {
      $fields[] = $key;
      $placeholders[] = ":$key";
    }

    $fields = implode(",", $fields);
    $placeholders = implode(",", $placeholders);

    $stmt = $this->connection()->prepare("insert into {$this->table} ($fields) values ($placeholders)");

    foreach($values as $key => $value) {
      $stmt->bindValue($key, $value);
    }

    $stmt->execute()->finalize();

    return $this->connection()->lastInsertRowID();
  }

  public function extraAction($row) {
    return '';
  }
}
