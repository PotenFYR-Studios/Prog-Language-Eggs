<?php
header('Content-Type: application/json');

echo json_encode([
    'status' => 'online',
    'message' => 'Hello from PotenFYR PHP Egg!',
    'php_version' => PHP_VERSION,
    'timestamp' => gmdate('Y-m-d\TH:i:s\Z')
], JSON_PRETTY_PRINT);
