<?php
header('Content-Type: text/plain');

// 定义需要检测的核心组件
$components = [
    'bcmath'     => '高精度计算',
    'gd'         => '图像处理',
    'pdo_mysql'  => 'MySQL PDO 扩展',
    'redis'      => 'Redis 扩展',
];

echo "--- PHP Component Load Check ---\n";

foreach ($components as $ext => $description) {
    if (extension_loaded($ext)) {
        echo "[ OK ] $ext ($description)\n";
    } else {
        echo "[FAIL] $ext ($description) - 请检查基础镜像编译日志！\n";
    }
}

echo "--------------------------------\n";
echo "PHP Version: " . PHP_VERSION . "\n";
?>
