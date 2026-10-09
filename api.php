<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "db_sarpras");

if ($conn->connect_error) {
    die(json_encode(["error" => "Koneksi database gagal"]));
}

$action = $_GET['action'] ?? '';

if ($action == 'register') {
    $data = json_decode(file_get_contents('php://input'), true);
    $nama = $conn->real_escape_string($data['nama']);
    $email = $conn->real_escape_string($data['email']);
    $password = $conn->real_escape_string($data['password']);
    
    $sql = "INSERT INTO users (nama, email, password, role) VALUES ('$nama', '$email', '$password', 'pelapor')";
    if ($conn->query($sql)) {
        echo json_encode(["message" => "Berhasil"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => $conn->error]);
    }
}

if ($action == 'login') {
    $data = json_decode(file_get_contents('php://input'), true);
    $email = $conn->real_escape_string($data['email']);
    $password = $conn->real_escape_string($data['password']);
    
    $result = $conn->query("SELECT id, nama, email, role FROM users WHERE email='$email' AND password='$password'");
    if ($result && $result->num_rows > 0) {
        echo json_encode(["user" => $result->fetch_assoc()]);
    } else {
        http_response_code(401);
        echo json_encode(["message" => "Email atau password salah"]);
    }
}

if ($action == 'get_pengaduan_user') {
    $user_id = $_GET['user_id'];
    $result = $conn->query("SELECT * FROM pengaduan WHERE user_id='$user_id' ORDER BY id DESC");
    $data = [];
    while ($row = $result->fetch_assoc()) { $data[] = $row; }
    echo json_encode($data);
}

if ($action == 'get_all_pengaduan') {
    $result = $conn->query("SELECT pengaduan.*, users.nama FROM pengaduan JOIN users ON pengaduan.user_id = users.id ORDER BY id DESC");
    $data = [];
    while ($row = $result->fetch_assoc()) { $data[] = $row; }
    echo json_encode($data);
}

if ($action == 'tambah_pengaduan') {
    $user_id = $_POST['user_id'];
    $judul = $conn->real_escape_string($_POST['judul']);
    $lokasi = $conn->real_escape_string($_POST['lokasi']);
    $deskripsi = $conn->real_escape_string($_POST['deskripsi']);
    $foto_url = null;

    if (isset($_FILES['foto'])) {
        if (!file_exists('uploads')) {
            mkdir('uploads', 0777, true);
        }
        $target = "uploads/" . time() . "_" . basename($_FILES['foto']['name']);
        if (move_uploaded_file($_FILES['foto']['tmp_name'], $target)) {
            $foto_url = $target;
        }
    }

    $sql = "INSERT INTO pengaduan (user_id, judul, lokasi, deskripsi, foto_url) VALUES ('$user_id', '$judul', '$lokasi', '$deskripsi', '$foto_url')";
    if ($conn->query($sql)) {
        echo json_encode(["message" => "Berhasil"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => $conn->error]);
    }
}

if ($action == 'update_tanggapan') {
    $data = json_decode(file_get_contents('php://input'), true);
    $id = $_GET['id'];
    $status = $data['status'];
    $tanggapan = $conn->real_escape_string($data['tanggapan']);
    $conn->query("UPDATE pengaduan SET status='$status', tanggapan='$tanggapan' WHERE id='$id'");
    echo json_encode(["message" => "Berhasil"]);
}

if ($action == 'rating') {
    $data = json_decode(file_get_contents('php://input'), true);
    $id = $_GET['id'];
    $penilaian = $data['penilaian'];
    $conn->query("UPDATE pengaduan SET penilaian='$penilaian' WHERE id='$id'");
    echo json_encode(["message" => "Berhasil"]);
}