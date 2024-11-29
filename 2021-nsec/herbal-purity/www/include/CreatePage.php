<?php

class CreatePage extends Page {
  public function setup() {
    $this->handleCreate();

    $this->form = new Form($this->model);
    $this->renderForm = $this->renderObject($this->form);
  }

  public function handleCreate() {
    if(!$this->isCreate()) {
      return;
    }

    foreach($this->model->fields as $key => $type) {
      $values[$key] = Utils::param($key);
    }

    $values['created_at'] = time();
    $values['updated_at'] = 0;

    $id = $this->model->insert($values);

    $this->flash->info('Success');

    $this->redirect($this->backUrl);
  }

  public function isCreate() {
    return Utils::param('action') == 'create';
  }
}
