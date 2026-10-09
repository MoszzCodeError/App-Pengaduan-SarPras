-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 09, 2026 at 04:43 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_sarpras`
--

-- --------------------------------------------------------

--
-- Table structure for table `pengaduan`
--

CREATE TABLE `pengaduan` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `judul` varchar(150) NOT NULL,
  `lokasi` varchar(150) NOT NULL,
  `deskripsi` text NOT NULL,
  `foto_url` varchar(255) DEFAULT NULL,
  `status` enum('Pending','Proses','Selesai') DEFAULT 'Pending',
  `tanggapan` text DEFAULT NULL,
  `penilaian` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengaduan`
--

INSERT INTO `pengaduan` (`id`, `user_id`, `judul`, `lokasi`, `deskripsi`, `foto_url`, `status`, `tanggapan`, `penilaian`, `created_at`) VALUES
(1, 2, 'Anshori', 'Lab ASM 1', 'Sakit Jiwa', 'uploads/1791510319_RobloxScreenShot20260806_095509588.png', 'Selesai', 'DONE DEK', 5, '2026-10-09 01:45:19'),
(2, 2, 'Surya', 'ASM 1', 'Sakit Jiwa', 'uploads/1791511087_RobloxScreenShot20260806_095509588.png', 'Pending', NULL, NULL, '2026-10-09 01:58:07'),
(3, 2, 'Tian', 'ASM 1', 'Pusing', 'uploads/1791511592_RobloxScreenShot20260806_095509588.png', 'Pending', NULL, NULL, '2026-10-09 02:06:32'),
(4, 2, 'asda', 'asdad', 'adsaddas', 'uploads/1791512610_RobloxScreenShot20260806_095509588.png', 'Pending', NULL, NULL, '2026-10-09 02:23:30');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('pelapor','petugas') DEFAULT 'pelapor'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`) VALUES
(1, 'Petugas Sarpras', 'admin@gmail.com', 'admin123', 'petugas'),
(2, 'Moses Adi Saputra', 'mosesadi954@gmail.com', 'Moses*123#', 'pelapor');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pengaduan`
--
ALTER TABLE `pengaduan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pengaduan`
--
ALTER TABLE `pengaduan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pengaduan`
--
ALTER TABLE `pengaduan`
  ADD CONSTRAINT `pengaduan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
