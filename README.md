# Web trắc nghiệm tuyển dụng Giúp Việc Nhanh

Chức năng:

- Nhập thông tin ứng viên trước khi làm bài
- Random 10 câu hỏi từ kho 100 câu trong database
- Bấm xác nhận để chấm điểm
- Đúng 8/10 là Đậu, dưới 8 là Rớt
- Một ứng viên có thể làm vô số lần
- Lưu lịch sử bài làm và chi tiết từng câu đúng/sai

## 1. Import database

Mở phpMyAdmin hoặc MySQL Workbench rồi chạy file:

```txt
database/gvn_database_trac_nghiem_random_full.sql
```

Database mặc định: `gvn_trac_nghiem`.

## 2. Cài thư viện

```bash
npm install
```

## 3. Cấu hình môi trường

Copy file `.env.example` thành `.env`:

```bash
cp .env.example .env
```

Nếu dùng XAMPP mặc định thì có thể để như sau:

```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=gvn_trac_nghiem
```

## 4. Chạy web

```bash
npm start
```

Mở trình duyệt:

```txt
http://localhost:3000
```

## API chính

### Bắt đầu làm bài

```http
POST /api/bai-lam/bat-dau
```

Body:

```json
{
  "ho_ten": "Nguyễn Văn A",
  "so_dien_thoai": "0900000000",
  "dia_chi": "TP Hồ Chí Minh",
  "nam_sinh": 1990
}
```

### Nộp bài

```http
POST /api/bai-lam/nop-bai
```

Body:

```json
{
  "id_bai_lam": 1,
  "dap_an": [
    { "id_cau_hoi": 1, "dap_an_chon": "A" }
  ]
}
```
