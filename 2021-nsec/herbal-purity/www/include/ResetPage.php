<?php

class ResetPage extends Page {
  public function setup() {
    $this->handleConfirm();
  }

  public function handleConfirm() {
    if(Utils::param('action') == 'Confirm') {
      $new_password = substr(sha1(rand()), 0, 8);
      $this->flash->info("New password: $new_password");
      $this->model->update($this->model_id, [ 'password_hash' => sha1($new_password) ]);

      $this->redirect($this->backUrl);
    }
  }
}
