<?php

class Appointments extends Model {
public $table = "appointments";
public $fields = ["date" => "string",
"time" => "string",
"healer" => "string"];

}
