<?php

class Flash {
  public function info($message) {
    $_SESSION['flash_message'] = $message;
  }

  public function render() {
    if(empty($_SESSION['flash_message'])) return;

    echo '<div id="flash">';
    echo e($_SESSION['flash_message']);
    echo '</div>';

    $_SESSION['flash_message'] = false;
  }
}
