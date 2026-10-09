import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String baseUrl = 'http://localhost/backend_sarpras/api.php';
const String imageBaseUrl = 'http://localhost/backend_sarpras/';

void main() {
  runApp(const MyApp());
}

Map<String, dynamic>? currentUser;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pengaduan Sarpras',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1976D2),
          secondary: const Color(0xFF00ACC1),
          surface: const Color(0xFFF4F6F9),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

// ==================== PREVIEW FOTO MODAL ====================
void showImagePreview(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Foto Bukti Kerusakan'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          InteractiveViewer(
            child: Image.network(
              Uri.encodeFull(imageUrl),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Gagal memuat gambar foto bukti.'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ==================== AUTH PAGE ====================
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nama = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (_email.text.isEmpty || _password.text.isEmpty || (!_isLogin && _nama.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua bidang form!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    final action = _isLogin ? 'login' : 'register';
    final body = _isLogin
        ? {'email': _email.text, 'password': _password.text}
        : {'nama': _nama.text, 'email': _email.text, 'password': _password.text};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl?action=$action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (_isLogin) {
          currentUser = res['user'];
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          }
        } else {
          setState(() => _isLogin = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pendaftaran berhasil! Silakan login dengan akun Anda.'), backgroundColor: Colors.green),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal. Periksa kembali email & password Anda.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal terhubung ke API: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.build_circle_rounded, size: 54, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLogin ? 'Pengaduan Sarpras' : 'Daftar Akun Siswa/Guru',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Masuk untuk melaporkan kerusakan sarana' : 'Buat akun pelapor baru',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    if (!_isLogin) ...[
                      TextField(
                        controller: _nama,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isLogin ? 'MASUK' : 'DAFTAR SEKARANG', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'Belum punya akun? Daftar di sini' : 'Sudah punya akun? Login'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = currentUser!['role'];
    final isPetugas = role == 'petugas';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(isPetugas ? Icons.admin_panel_settings : Icons.school, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pengaduan Sarpras (${isPetugas ? 'Petugas' : 'Pelapor'})',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 18, color: Colors.blue),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    currentUser!['nama'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () {
              currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
            },
          )
        ],
      ),
      body: role == 'pelapor' ? const PelaporView() : const PetugasView(),
      floatingActionButton: role == 'pelapor'
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('Buat Pengaduan'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPengaduanPage())),
            )
          : null,
    );
  }
}

// ==================== PELAPOR VIEW ====================
class PelaporView extends StatefulWidget {
  const PelaporView({super.key});
  @override
  State<PelaporView> createState() => _PelaporViewState();
}

class _PelaporViewState extends State<PelaporView> {
  List data = [];
  Timer? _timer;

  Future<void> _loadData() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=get_pengaduan_user&user_id=${currentUser!['id']}'));
      if (res.statusCode == 200 && mounted) {
        setState(() => data = jsonDecode(res.body));
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _giveRating(int id) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Umpan Balik / Penilaian Perbaikan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan penilaian atas tindakan perbaikan sarana oleh petugas:'),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setSt) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () => setSt(() => rating = index + 1),
                  );
                }),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await http.post(
                Uri.parse('$baseUrl?action=rating&id=$id'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'penilaian': rating}),
              );
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text('Kirim Penilaian'),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.red.shade100;
    Color fg = Colors.red.shade900;
    IconData icon = Icons.pending_actions;

    if (status == 'Proses') {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
      icon = Icons.autorenew;
    } else if (status == 'Selesai') {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada riwayat pengaduan', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];
              final hasFoto = item['foto_url'] != null && item['foto_url'].toString().isNotEmpty;
              final fullImageUrl = hasFoto ? '$imageBaseUrl${item['foto_url']}' : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item['judul'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          _buildStatusBadge(item['status']),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Lokasi: ${item['lokasi']}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item['deskripsi'], style: const TextStyle(fontSize: 14)),
                      if (hasFoto) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => showImagePreview(context, fullImageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Image.network(
                                    Uri.encodeFull(fullImageUrl),
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Text('Foto gagal dimuat')),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Klik Foto', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.question_answer_outlined, size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tanggapan Petugas: ${item['tanggapan'] ?? 'Belum ada tanggapan/tindakan.'}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (item['status'] == 'Selesai' && item['penilaian'] == null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.star_half_rounded),
                            label: const Text('Beri Umpan Balik'),
                            onPressed: () => _giveRating(int.parse(item['id'].toString())),
                          ),
                        )
                      else if (item['penilaian'] != null)
                        Row(
                          children: [
                            const Text('Umpan Balik Anda: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(
                                int.parse(item['penilaian'].toString()),
                                (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

// ==================== FORM PENGADUAN ====================
class FormPengaduanPage extends StatefulWidget {
  const FormPengaduanPage({super.key});
  @override
  State<FormPengaduanPage> createState() => _FormPengaduanPageState();
}

class _FormPengaduanPageState extends State<FormPengaduanPage> {
  final _judul = TextEditingController();
  final _lokasi = TextEditingController();
  final _deskripsi = TextEditingController();
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource src) async {
    final picked = await ImagePicker().pickImage(source: src);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _image = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (_judul.text.isEmpty || _lokasi.text.isEmpty || _deskripsi.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi seluruh formulir')));
      return;
    }

    setState(() => _isUploading = true);
    var req = http.MultipartRequest('POST', Uri.parse('$baseUrl?action=tambah_pengaduan'));
    req.fields['user_id'] = currentUser!['id'].toString();
    req.fields['judul'] = _judul.text;
    req.fields['lokasi'] = _lokasi.text;
    req.fields['deskripsi'] = _deskripsi.text;

    if (_imageBytes != null && _image != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          _imageBytes!,
          filename: _image!.name,
        ),
      );
    }

    await req.send();
    setState(() => _isUploading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pengaduan Sarana')),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(controller: _judul, decoration: const InputDecoration(labelText: 'Judul Pengaduan / Nama Sarana', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _lokasi, decoration: const InputDecoration(labelText: 'Lokasi Sarana (Misal: Ruang Kelas X-RPL)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _deskripsi, maxLines: 4, decoration: const InputDecoration(labelText: 'Deskripsi Kerusakan', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Kamera')),
                  OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Galeri')),
                ],
              ),
              if (_image != null) Padding(padding: const EdgeInsets.all(8.0), child: Text('Bukti Foto: ${_image!.name}', style: const TextStyle(color: Colors.green))),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submit,
                  child: _isUploading ? const CircularProgressIndicator() : const Text('KIRIM LAPORAN'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PETUGAS VIEW ====================
class PetugasView extends StatefulWidget {
  const PetugasView({super.key});
  @override
  State<PetugasView> createState() => _PetugasViewState();
}

class _PetugasViewState extends State<PetugasView> {
  List data = [];
  Timer? _timer;

  Future<void> _loadData() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl?action=get_all_pengaduan'));
      if (res.statusCode == 200 && mounted) {
        setState(() => data = jsonDecode(res.body));
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cetakPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'REKAPITULASI LAPORAN PENGADUAN SARANA SEKOLAH',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),
            pw.TableHelper.fromTextArray(
              headers: ['Pelapor', 'Judul Sarana', 'Lokasi', 'Status', 'Tanggapan/Tindakan', 'Rating'],
              data: data.map((e) => [
                e['nama'],
                e['judul'],
                e['lokasi'],
                e['status'],
                e['tanggapan'] ?? '-',
                e['penilaian'] != null ? "${e['penilaian']} / 5" : '-'
              ]).toList(),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _updateStatus(Map item) {
    if (item['status'] == 'Selesai') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaduan berstatus Selesai sudah tidak dapat diubah lagi.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String status = item['status'];
    final tanggapan = TextEditingController(text: item['tanggapan']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tindak Lanjut & Tanggapan Pengaduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: status,
              items: ['Pending', 'Proses', 'Selesai']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => status = v!,
              decoration: const InputDecoration(labelText: 'Pembaruan Status Penanganan', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tanggapan,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Tindakan / Tanggapan Perbaikan', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await http.post(
                Uri.parse('$baseUrl?action=update_tanggapan&id=${item['id']}'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'status': status, 'tanggapan': tanggapan.text}),
              );
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text('Simpan & Update'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pengaduan: ${data.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: _cetakPdf,
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Cetak Rekap PDF'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];
              final isSelesai = item['status'] == 'Selesai';
              final hasFoto = item['foto_url'] != null && item['foto_url'].toString().isNotEmpty;
              final fullImageUrl = hasFoto ? '$imageBaseUrl${item['foto_url']}' : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['judul']} (Pelapor: ${item['nama']})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelesai ? Colors.green.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Status: ${item['status']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelesai ? Colors.green.shade900 : Colors.blue.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Lokasi: ${item['lokasi']}'),
                      Text('Deskripsi Kerusakan: ${item['deskripsi']}'),
                      if (hasFoto) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => showImagePreview(context, fullImageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Image.network(
                                    Uri.encodeFull(fullImageUrl),
                                    width: double.infinity,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Text('Foto gagal dimuat')),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Lihat Foto Bukti', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text('Tanggapan Petugas: ${item['tanggapan'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      if (item['penilaian'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Penilaian/Rating Pelapor: ${item['penilaian']} / 5 Bintang ⭐',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: isSelesai
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock, size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('Selesai (Terkunci)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              )
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Proses / Tanggapi'),
                                onPressed: () => _updateStatus(item),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}