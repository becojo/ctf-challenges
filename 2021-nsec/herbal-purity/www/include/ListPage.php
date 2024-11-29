<?php

class ListPage extends Page {
  public function setup() {
    $table = new Table($this->model);

    $this->renderTable = $this->renderObject($table);
    $this->searchForm = $this->renderObject(new SearchForm($this->model));
  }
}
