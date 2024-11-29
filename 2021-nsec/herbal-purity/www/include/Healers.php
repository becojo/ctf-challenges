<?php

class Healers extends Model {
public $table = "healers";
public $fields = ["name" => "string",
"password_hash" => "string"];

public function extraAction($row) { 
  return ' - <a href="reset_healers.php?name='.e($row[3]).'&id='.e($row[0]).'">Reset</a>'; 
}

}
