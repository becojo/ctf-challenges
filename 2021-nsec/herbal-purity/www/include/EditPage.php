<?php

class EditPage extends Page {
  public function setup() {
    $this->object = $this->model->get($this->model_id);

    $this->handleNotFound($this->object);
    $this->handleEdit();

    $this->form = new Form($this->model, $this->object);

    $this->renderForm = $this->renderObject($this->form);
  }

  public function handleEdit() {
    if(!$this->isEdit()) {
      return;
    }

    $updates = [];

    foreach($this->model->fields as $key => $type) {
      $updates[$key] = Utils::param($key);
    }

    $updates['updated_at'] = time();

    $success = $this->model->update($this->model_id, $updates);

    $this->flash->info($success ? "Update successful" : "Error while updating");

    $this->redirect($this->backUrl);
  }

  public function isEdit() {
    return Utils::param('action') == 'edit';
  }
}
