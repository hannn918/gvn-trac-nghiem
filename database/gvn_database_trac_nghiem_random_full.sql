-- Database trắc nghiệm tuyển dụng Giúp Việc Nhanh
-- Mô hình: 100 câu hỏi trong kho, mỗi lần làm random 10 câu
-- Đậu nếu đúng >= 8/10, rớt nếu đúng < 8/10

CREATE DATABASE IF NOT EXISTS gvn_trac_nghiem
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE gvn_trac_nghiem;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS chi_tiet_bai_lam;
DROP TABLE IF EXISTS bai_lam;
DROP TABLE IF EXISTS cau_hoi;
DROP TABLE IF EXISTS ung_vien;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE ung_vien (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ho_ten VARCHAR(100) NOT NULL,
    so_dien_thoai VARCHAR(20) NOT NULL,
    dia_chi VARCHAR(255) NULL,
    nam_sinh YEAR NULL,
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sdt (so_dien_thoai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cau_hoi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    noi_dung TEXT NOT NULL,
    dap_an_a VARCHAR(500) NOT NULL,
    dap_an_b VARCHAR(500) NOT NULL,
    dap_an_c VARCHAR(500) NOT NULL,
    dap_an_d VARCHAR(500) NOT NULL,
    dap_an_dung ENUM('A', 'B', 'C', 'D') NOT NULL,
    nhom_cau_hoi VARCHAR(100) NULL,
    trang_thai ENUM('hoat_dong', 'tam_an') DEFAULT 'hoat_dong',
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bai_lam (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ung_vien INT NOT NULL,
    tong_cau INT DEFAULT 10,
    so_cau_dung INT DEFAULT 0,
    so_cau_sai INT DEFAULT 0,
    diem DECIMAL(5,2) DEFAULT 0.00,
    ket_qua ENUM('dau', 'rot') NULL,
    thoi_gian_bat_dau DATETIME DEFAULT CURRENT_TIMESTAMP,
    thoi_gian_nop DATETIME NULL,
    trang_thai ENUM('dang_lam', 'da_nop') DEFAULT 'dang_lam',
    CONSTRAINT fk_bai_lam_ung_vien FOREIGN KEY (id_ung_vien) REFERENCES ung_vien(id) ON DELETE CASCADE,
    INDEX idx_bai_lam_ung_vien (id_ung_vien),
    INDEX idx_bai_lam_ket_qua (ket_qua)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chi_tiet_bai_lam (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_bai_lam INT NOT NULL,
    id_cau_hoi INT NOT NULL,
    thu_tu INT NOT NULL,
    dap_an_chon ENUM('A', 'B', 'C', 'D') NULL,
    dap_an_dung ENUM('A', 'B', 'C', 'D') NOT NULL,
    la_dung TINYINT(1) DEFAULT 0,
    CONSTRAINT fk_chi_tiet_bai_lam FOREIGN KEY (id_bai_lam) REFERENCES bai_lam(id) ON DELETE CASCADE,
    CONSTRAINT fk_chi_tiet_cau_hoi FOREIGN KEY (id_cau_hoi) REFERENCES cau_hoi(id) ON DELETE CASCADE,
    UNIQUE KEY uk_bai_lam_cau_hoi (id_bai_lam, id_cau_hoi),
    INDEX idx_chi_tiet_bai_lam (id_bai_lam)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert đầy đủ 100 câu hỏi
INSERT INTO cau_hoi (noi_dung, dap_an_a, dap_an_b, dap_an_c, dap_an_d, dap_an_dung, nhom_cau_hoi) VALUES
('Trước khi bắt đầu vệ sinh nhà, việc nên làm là gì?', 'Kiểm tra phạm vi công việc và dụng cụ', 'Lau sàn ngay', 'Di chuyển đồ của khách', 'Mở tất cả cửa tủ', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau bụi trong phòng, nên thực hiện theo thứ tự nào?', 'Từ thấp lên cao', 'Từ cao xuống thấp', 'Từ cửa ra giữa phòng', 'Làm vị trí bất kỳ', 'B', 'Vệ sinh nhà cơ bản'),
('Trước khi lau sàn, cần làm gì?', 'Xịt nước thật nhiều', 'Quét hoặc hút bụi', 'Lau kính trước', 'Đổ hóa chất trực tiếp', 'B', 'Vệ sinh nhà cơ bản'),
('Khăn lau bề mặt bàn và khăn lau sàn nên như thế nào?', 'Dùng chung', 'Dùng riêng', 'Chỉ dùng một khăn', 'Không cần phân biệt', 'B', 'Vệ sinh nhà cơ bản'),
('Khi lau bàn gỗ, nên dùng dụng cụ nào?', 'Khăn mềm, sạch, vắt ráo', 'Bàn chải sắt', 'Giấy nhám', 'Miếng cọ kim loại', 'A', 'Vệ sinh nhà cơ bản'),
('Khi phát hiện bề mặt dễ trầy xước, nên làm gì?', 'Chà mạnh', 'Dùng vật sắc để cạo', 'Thử ở vị trí nhỏ và dùng khăn mềm', 'Bỏ qua không vệ sinh', 'C', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh kính, nên dùng khăn nào?', 'Khăn sạch, ít xơ', 'Khăn lau sàn', 'Khăn bẩn', 'Khăn có cát', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau kính, cách làm phù hợp là gì?', 'Lau theo một chiều', 'Lau ngẫu nhiên', 'Dùng vật nhọn cạo mạnh', 'Chỉ lau một góc', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh gương, cần tránh điều gì?', 'Dùng khăn mềm', 'Xịt quá nhiều dung dịch vào mép gương', 'Lau từ trên xuống', 'Kiểm tra vết nước', 'B', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh sàn, nên chọn dụng cụ phù hợp với điều gì?', 'Dụng cụ nào có sẵn cũng được', 'Dụng cụ phù hợp với từng loại sàn', 'Chỉ dùng bàn chải sắt', 'Chỉ dùng khăn thật ướt', 'B', 'Vệ sinh nhà cơ bản'),
('Sàn đang ướt cần được xử lý như thế nào?', 'Để mọi người đi qua', 'Đặt cảnh báo khu vực trơn', 'Đóng cửa và bỏ đi', 'Lau bằng khăn bẩn', 'B', 'Vệ sinh nhà cơ bản'),
('Khi lau cầu thang, nên làm thế nào?', 'Lau từng bậc cẩn thận', 'Lau thật nhanh', 'Đứng trên bậc ướt', 'Đổ nhiều nước lên cầu thang', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh khu vực có nhiều đồ đạc, nên làm gì?', 'Tự ý bỏ đồ đi', 'Di chuyển nhẹ nhàng và đặt lại đúng vị trí', 'Để đồ xuống sàn lẫn lộn', 'Không cần lau', 'B', 'Vệ sinh nhà cơ bản'),
('Khi phát hiện đồ vật có giá trị, nên làm gì?', 'Tự cất giữ', 'Báo khách hoặc quản lý nếu cần di chuyển', 'Chụp ảnh đăng mạng', 'Mang về', 'B', 'Vệ sinh nhà cơ bản'),
('Sau khi dùng dụng cụ vệ sinh, nên làm gì?', 'Để tại chỗ', 'Vệ sinh và cất đúng nơi', 'Mang về nhà', 'Bỏ vào thùng rác', 'B', 'Vệ sinh nhà cơ bản'),
('Thùng rác đầy cần được xử lý thế nào?', 'Nén thêm thật chặt', 'Thu gom và bỏ đúng nơi quy định', 'Để hôm sau', 'Đổ sang góc phòng', 'B', 'Vệ sinh nhà cơ bản'),
('Khi thay túi rác, cần làm gì?', 'Dùng túi phù hợp và buộc kín', 'Không cần túi', 'Để rác trực tiếp xuống sàn', 'Dùng túi rách', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh rèm hoặc màn cửa, nên ưu tiên gì?', 'Kiểm tra hướng dẫn của khách hoặc loại rèm', 'Kéo mạnh', 'Dùng nước thật nhiều', 'Tự tháo tất cả', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh quạt điện, việc đầu tiên là gì?', 'Rút nguồn điện', 'Bật quạt tốc độ cao', 'Xịt nước trực tiếp', 'Dùng tay chạm cánh quạt', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh thiết bị điện, không nên làm gì?', 'Rút điện trước', 'Dùng khăn ẩm vắt kỹ', 'Đổ nước trực tiếp vào thiết bị', 'Lau phần bên ngoài', 'C', 'Vệ sinh nhà cơ bản'),
('Khi dùng máy hút bụi, cần kiểm tra gì?', 'Dây điện và hộp chứa bụi', 'Màu máy', 'Tên khách', 'Màu sàn', 'A', 'Vệ sinh nhà cơ bản'),
('Máy hút bụi đầy bụi cần làm gì?', 'Tiếp tục dùng', 'Đổ bụi theo hướng dẫn', 'Đổ nước vào máy', 'Đập máy', 'B', 'Vệ sinh nhà cơ bản'),
('Khi hút bụi thảm, nên làm gì?', 'Hút từ từ theo từng khu vực', 'Chạy máy thật nhanh', 'Đổ nước lên thảm', 'Dùng chổi sắt', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh sofa vải, nên làm gì trước?', 'Kiểm tra nhãn hoặc hỏi khách về cách vệ sinh', 'Xịt hóa chất bất kỳ', 'Dùng bàn chải sắt', 'Đổ nước trực tiếp', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh sofa da, nên ưu tiên gì?', 'Khăn mềm và dung dịch phù hợp', 'Nước tẩy mạnh', 'Miếng cọ kim loại', 'Ngâm nước', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau tay nắm cửa, cần chú ý gì?', 'Lau sạch cả mặt trong và ngoài', 'Chỉ lau một bên', 'Không cần lau', 'Dùng khăn lau sàn', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh công tắc điện, nên làm gì?', 'Dùng khăn khô hoặc khăn ẩm vắt kỹ', 'Xịt nước trực tiếp', 'Dùng tay ướt', 'Dùng hóa chất mạnh', 'A', 'Vệ sinh nhà cơ bản'),
('Khi phát hiện vết bẩn khó xử lý, nên làm gì?', 'Dùng đúng dung dịch phù hợp và thử trước', 'Cạo bằng dao', 'Chà thật mạnh', 'Bỏ qua ngay', 'A', 'Vệ sinh nhà cơ bản'),
('Không nên trộn các loại hóa chất tẩy rửa vì sao?', 'Có thể gây phản ứng nguy hiểm', 'Giúp sạch hơn', 'Tiết kiệm hơn', 'Làm thơm hơn', 'A', 'Vệ sinh nhà cơ bản'),
('Khi dùng hóa chất, cần làm gì?', 'Đọc hướng dẫn và dùng đúng liều lượng', 'Dùng càng nhiều càng tốt', 'Trộn với mọi dung dịch', 'Để gần trẻ em', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau chân tường, nên chú ý gì?', 'Các góc khuất dễ bám bụi', 'Chỉ lau giữa phòng', 'Không cần lau', 'Dùng dao cạo mạnh', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh cửa ra vào, khu vực cần lau kỹ là gì?', 'Tay nắm, mép cửa và dấu tay', 'Chỉ lau phần giữa cửa', 'Chỉ lau phía trên', 'Không cần lau tay nắm', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh phòng ngủ, nên ưu tiên điều gì?', 'Mở tủ cá nhân', 'Gọn gàng, sạch bụi, không xáo trộn đồ riêng', 'Tự ý bỏ đồ', 'Di chuyển toàn bộ đồ đạc', 'B', 'Vệ sinh nhà cơ bản'),
('Khi làm sạch kệ tủ, nên làm gì?', 'Lau từng ngăn và đặt đồ lại đúng vị trí', 'Dồn đồ vào một góc', 'Bỏ hết đồ ra ngoài', 'Không cần lau bên trong nếu đã mở', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh ban công, cần chú ý gì?', 'An toàn, không đổ nước xuống dưới', 'Đổ nước thật nhiều xuống dưới', 'Leo ra lan can', 'Để dụng cụ ngoài mép ban công', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau cửa sổ, cần tránh điều gì?', 'Dùng khăn sạch', 'Đứng ở vị trí nguy hiểm', 'Lau vết tay', 'Kiểm tra mép kính', 'B', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh đồ trang trí dễ vỡ, nên làm gì?', 'Cầm nhẹ nhàng, lau bằng khăn mềm', 'Cầm nhiều món cùng lúc', 'Đặt sát mép bàn', 'Chà mạnh bằng bàn chải', 'A', 'Vệ sinh nhà cơ bản'),
('Khi thấy côn trùng chết trên sàn, nên làm gì?', 'Thu gom và vệ sinh khu vực đó', 'Đá vào góc phòng', 'Bỏ qua', 'Dùng tay không nhặt', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh khu vực có thú cưng, nên chú ý gì?', 'Dọn lông, rác nhỏ và tránh làm thú cưng hoảng sợ', 'Đuổi thú cưng mạnh tay', 'Dùng hóa chất nồng ngay gần thú cưng', 'Không cần dọn lông', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau sàn gỗ, không nên làm gì?', 'Dùng quá nhiều nước', 'Dùng khăn vắt ráo', 'Lau nhẹ nhàng', 'Kiểm tra vết bẩn', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau sàn gạch, nên làm gì?', 'Để nước đọng lâu', 'Chỉ lau giữa phòng', 'Lau đều và xử lý vết bẩn ở khe gạch', 'Dùng hóa chất bất kỳ', 'C', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh tường bị bám bụi, nên làm gì?', 'Dùng khăn mềm hoặc dụng cụ phù hợp', 'Chà bằng giấy nhám', 'Đổ nước lên tường', 'Cạo bằng dao', 'A', 'Vệ sinh nhà cơ bản'),
('Khi dọn phòng khách, điều nào là đúng?', 'Chỉ lau sàn là đủ', 'Tự ý mở ngăn kéo', 'Bỏ đồ khách vào túi', 'Sắp xếp gọn, lau bụi, hút/quét sàn', 'B', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh khu vực thờ cúng nếu có, nên làm gì?', 'Bỏ đồ cúng đi', 'Tự ý thay đổi vị trí', 'Hỏi khách trước khi di chuyển hoặc lau dọn', 'Lau bằng khăn bẩn', 'C', 'Vệ sinh nhà cơ bản'),
('Khi phát hiện đồ bị hư trước khi làm, nên làm gì?', 'Báo khách hoặc chụp xác nhận theo quy định', 'Im lặng', 'Tự sửa', 'Bỏ vào thùng rác', 'A', 'Vệ sinh nhà cơ bản'),
('Khi cần dùng nước lau sàn, nên pha như thế nào?', 'Theo hướng dẫn sử dụng', 'Càng đặc càng tốt', 'Pha với mọi hóa chất khác', 'Không cần pha đúng', 'A', 'Vệ sinh nhà cơ bản'),
('Khi vệ sinh góc khuất dưới bàn ghế, nên làm gì?', 'Di chuyển nhẹ nếu cần và lau kỹ', 'Bỏ qua vì khó lau', 'Kéo mạnh làm trầy sàn', 'Chỉ lau phần nhìn thấy', 'A', 'Vệ sinh nhà cơ bản'),
('Khi lau bụi kệ cao, nên dùng gì?', 'Dụng cụ nối dài hoặc thang chắc chắn', 'Ghế yếu', 'Đứng lên bàn kính', 'Leo lên kệ', 'A', 'Vệ sinh nhà cơ bản'),
('Khi kết thúc vệ sinh nhà, nên làm gì?', 'Kiểm tra lại toàn bộ khu vực đã làm', 'Về ngay không báo', 'Để dụng cụ lung tung', 'Không cần xem lại', 'A', 'Vệ sinh nhà cơ bản'),
('Tiêu chuẩn vệ sinh nhà cơ bản là gì?', 'Sạch, gọn, an toàn, đúng yêu cầu', 'Chỉ cần làm nhanh', 'Chỉ cần thơm', 'Chỉ cần lau sàn', 'A', 'Vệ sinh nhà cơ bản'),
('Trước khi vệ sinh văn phòng, nên làm gì?', 'Kiểm tra khu vực và yêu cầu công việc', 'Tự ý di chuyển hồ sơ', 'Tắt toàn bộ máy tính', 'Mở tủ cá nhân', 'A', 'Vệ sinh văn phòng'),
('Khi lau bàn làm việc văn phòng, cần lưu ý gì?', 'Tự ý đọc hồ sơ', 'Gộp tất cả giấy tờ lại', 'Vứt giấy trên bàn', 'Không làm xáo trộn tài liệu', 'D', 'Vệ sinh văn phòng'),
('Khi gặp tài liệu trên bàn làm việc, nên làm gì?', 'Giữ nguyên vị trí hoặc hỏi người phụ trách', 'Tự ý sắp xếp lại', 'Mang đi', 'Bỏ vào thùng rác', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh máy tính, nên làm gì?', 'Lau bên ngoài bằng khăn phù hợp', 'Xịt nước lên màn hình', 'Rút dây tùy ý', 'Tự ý mở máy', 'A', 'Vệ sinh văn phòng'),
('Khi lau màn hình máy tính, nên dùng gì?', 'Khăn mềm, khô hoặc dung dịch phù hợp', 'Khăn lau sàn ướt', 'Bàn chải sắt', 'Giấy nhám', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh bàn phím, nên làm gì?', 'Lau nhẹ, tránh để nước lọt vào khe', 'Đổ nước trực tiếp', 'Dùng vật nhọn chọc mạnh', 'Ngâm nước', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh khu vực ổ điện văn phòng, cần làm gì?', 'Tránh làm ướt và báo nếu có dấu hiệu hư hỏng', 'Xịt dung dịch trực tiếp', 'Chạm thử bằng tay ướt', 'Tự tháo ổ điện', 'A', 'Vệ sinh văn phòng'),
('Khi lau sàn văn phòng, nên làm theo hướng nào?', 'Lau ngẫu nhiên', 'Từ cửa vào trong', 'Từ trong ra ngoài, tránh chặn lối đi', 'Lau nơi đông người trước', 'C', 'Vệ sinh văn phòng'),
('Khi có người đang làm việc gần khu vực vệ sinh, nên làm gì?', 'Thông báo lịch sự và vệ sinh nhẹ nhàng', 'Làm ồn lớn', 'Di chuyển đồ của họ', 'Yêu cầu họ rời đi', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh phòng họp, cần kiểm tra gì sau khi xong?', 'Bàn ghế gọn, sàn sạch, rác đã thu gom', 'Có thay đổi hồ sơ không', 'Có ai để đồ cá nhân không', 'Đèn có bật hết không', 'A', 'Vệ sinh văn phòng'),
('Khi sắp xếp ghế phòng họp, nên làm gì?', 'Đặt ngay ngắn theo bố cục có sẵn', 'Xếp chồng tất cả ghế', 'Để lệch tùy ý', 'Mang ghế sang phòng khác', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh bảng trắng, nên dùng gì?', 'Khăn mềm và dung dịch phù hợp', 'Nước tẩy mạnh', 'Vật sắc nhọn', 'Khăn lau sàn', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh thùng rác văn phòng, cần chú ý gì?', 'Để rác cạnh thùng', 'Chỉ đổ rác, không thay túi', 'Thay túi rác và giữ khu vực sạch', 'Không cần kiểm tra', 'C', 'Vệ sinh văn phòng'),
('Khi vệ sinh khu vực lễ tân, ưu tiên là gì?', 'Sạch sẽ, gọn gàng, tạo ấn tượng tốt', 'Di chuyển tài liệu tùy ý', 'Để dụng cụ lộ ra', 'Làm ồn', 'A', 'Vệ sinh văn phòng'),
('Khi lau cửa kính văn phòng, nên chú ý gì?', 'Không để lại vệt nước và dấu tay', 'Lau bằng khăn bẩn', 'Chỉ lau phần thấp', 'Xịt nước xuống sàn', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh nhà vệ sinh văn phòng, cần dùng gì?', 'Khăn lau kính', 'Khăn lau bàn làm việc', 'Dụng cụ và khăn riêng cho khu vực này', 'Dùng chung mọi khăn', 'C', 'Vệ sinh văn phòng'),
('Khi vệ sinh nhà vệ sinh, nên làm theo nguyên tắc nào?', 'Từ khu vực sạch hơn đến khu vực bẩn hơn', 'Từ bồn cầu ra cửa', 'Làm ngẫu nhiên', 'Chỉ lau sàn', 'A', 'Vệ sinh văn phòng'),
('Sau khi vệ sinh nhà vệ sinh, cần kiểm tra gì?', 'Sàn khô tương đối, thùng rác gọn, không còn mùi khó chịu', 'Chỉ kiểm tra cửa', 'Chỉ kiểm tra gương', 'Không cần kiểm tra', 'A', 'Vệ sinh văn phòng'),
('Khi thấy giấy hoặc rác nhỏ trên sàn văn phòng, nên làm gì?', 'Thu gom ngay', 'Để cuối ngày', 'Đá vào góc', 'Bỏ qua', 'A', 'Vệ sinh văn phòng'),
('Khi phát hiện nước đổ trên sàn văn phòng, nên làm gì?', 'Để tự khô', 'Lau ngay và đặt cảnh báo nếu cần', 'Đi qua bình thường', 'Đổ thêm nước', 'B', 'Vệ sinh văn phòng'),
('Khi vệ sinh hành lang, cần chú ý gì?', 'Không cản trở lối đi và đặt biển cảnh báo khi sàn ướt', 'Để xe dụng cụ giữa lối', 'Lau vào giờ đông người mà không báo', 'Đóng hết lối đi', 'A', 'Vệ sinh văn phòng'),
('Khi vệ sinh khu vực thang máy, nên làm gì?', 'Lau sạch tay nắm, nút bấm bên ngoài và sàn khu vực chờ', 'Xịt nước vào bảng nút bấm', 'Tự ý mở cửa thang máy', 'Không cần lau', 'A', 'Vệ sinh văn phòng'),
('Khi làm sạch vết bẩn trên sàn, cần làm gì trước?', 'Xác định loại sàn và loại vết bẩn', 'Dùng hóa chất mạnh ngay', 'Cạo bằng vật nhọn', 'Đổ nước nóng lên mọi loại sàn', 'A', 'An toàn và quy tắc làm việc'),
('Khi cần di chuyển vật nặng, nên làm gì?', 'Nhờ hỗ trợ hoặc dùng dụng cụ phù hợp', 'Tự bê quá sức', 'Kéo lê trên sàn', 'Nâng bằng tư thế cúi gập lưng', 'A', 'An toàn và quy tắc làm việc'),
('Khi thấy dây điện bị hở, nên làm gì?', 'Tránh xa và báo người phụ trách', 'Chạm thử', 'Dùng băng dính tự sửa', 'Đổ nước kiểm tra', 'A', 'An toàn và quy tắc làm việc'),
('Khi làm việc ở khu vực có sàn trơn, nên mang gì?', 'Giày chống trượt phù hợp', 'Dép trơn', 'Giày cao gót', 'Đi chân trần', 'A', 'An toàn và quy tắc làm việc'),
('Khi bị hóa chất bắn vào mắt, cần làm gì?', 'Rửa ngay bằng nước sạch và báo người phụ trách', 'Dụi mắt', 'Chờ tự hết', 'Tiếp tục làm việc', 'A', 'An toàn và quy tắc làm việc'),
('Khi hóa chất dính vào da, nên làm gì?', 'Rửa sạch theo hướng dẫn và báo nếu có kích ứng', 'Lau qua loa', 'Bôi thêm hóa chất', 'Bỏ qua', 'A', 'An toàn và quy tắc làm việc'),
('Khi có sự cố nhỏ trong khu vực làm việc, nên ưu tiên gì?', 'Bảo đảm an toàn và báo người phụ trách', 'Quay video', 'Bỏ đi không báo', 'Tự ý xử lý vượt khả năng', 'A', 'An toàn và quy tắc làm việc'),
('Khi khách hàng góp ý về vệ sinh, nên làm gì?', 'Lắng nghe, xin lỗi nếu cần và khắc phục', 'Tranh cãi', 'Bỏ về', 'Phớt lờ', 'A', 'An toàn và quy tắc làm việc'),
('Khi chưa rõ yêu cầu công việc, nên làm gì?', 'Hỏi lại khách hoặc quản lý', 'Tự đoán', 'Làm theo ý mình', 'Bỏ qua khu vực đó', 'A', 'An toàn và quy tắc làm việc'),
('Khi khách yêu cầu làm thêm ngoài phạm vi ban đầu, nên làm gì?', 'Tự ý nhận tiền', 'Báo lại để xác nhận phạm vi theo quy định', 'Từ chối không giải thích', 'Làm xong rồi mới báo', 'B', 'An toàn và quy tắc làm việc'),
('Khi đến trễ giờ làm, nên làm gì?', 'Đến muộn và im lặng', 'Không cần báo', 'Tự hủy đơn', 'Thông báo sớm cho khách hoặc quản lý', 'D', 'An toàn và quy tắc làm việc'),
('Khi không thể đến làm đúng lịch, nên làm gì?', 'Để khách tự biét', 'Tắt điện thoại', 'Báo sớm theo quy định công ty', 'Nhờ người lạ thay thế', 'C', 'An toàn và quy tắc làm việc'),
('Khi làm hư hỏng đồ của khách, nên làm gì?', 'Báo ngay, trung thực mô tả sự việc', 'Giấu đi', 'Đổ lỗi người khác', 'Tự ý bỏ đi', 'A', 'An toàn và quy tắc làm việc'),
('Khi tìm thấy tiền hoặc tài sản của khách, nên làm gì?', 'Giữ nguyên vị trí hoặc báo ngay cho khách/quản lý', 'Mang về', 'Chụp ảnh đăng mạng', 'Cất riêng không nói', 'A', 'An toàn và quy tắc làm việc'),
('Thông tin về khách hàng cần được xử lý thế nào?', 'Giữ bảo mật', 'Kể cho bạn bè', 'Đăng mạng xã hội', 'Chia sẻ tùy ý', 'A', 'An toàn và quy tắc làm việc'),
('Trong giờ làm việc, nên sử dụng điện thoại như thế nào?', 'Chỉ dùng khi cần thiết cho công việc hoặc tình huống khẩn', 'Dùng liên tục', 'Xem video', 'Gọi chuyện riêng lâu', 'A', 'An toàn và quy tắc làm việc'),
('Trang phục làm việc phù hợp là gì?', 'Đồ ngủ', 'Sạch sẽ, gọn gàng, thuận tiện vận động', 'Trang phục quá vướng víu', 'Dép trơn', 'B', 'An toàn và quy tắc làm việc'),
('Khi vào nhà hoặc văn phòng khách, nên làm gì?', 'Chào hỏi lịch sự và xác nhận công việc', 'Tự ý đi vào mọi phòng', 'Mở tủ kiểm tra', 'Dùng đồ cá nhân của khách', 'A', 'An toàn và quy tắc làm việc'),
('Khi hoàn thành công việc, nên làm gì?', 'Kiểm tra lại khu vực và báo bàn giao', 'Rời đi ngay', 'Để dụng cụ lại lung tung', 'Không cần báo', 'A', 'An toàn và quy tắc làm việc'),
('Khi khách không có mặt, nhân viên nên làm gì?', 'Chỉ làm trong phạm vi đã thống nhất', 'Tự ý mở tủ', 'Dùng đồ cá nhân', 'Mời người quen vào', 'A', 'An toàn và quy tắc làm việc'),
('Khi gặp khu vực riêng tư của khách, nên làm gì?', 'Tự ý kiểm tra', 'Tôn trọng riêng tư và chỉ vệ sinh khi được yêu cầu', 'Chụp ảnh', 'Kể chuyện với người khác', 'B', 'An toàn và quy tắc làm việc'),
('Khi cần nghỉ giữa giờ, nên làm gì?', 'Xin phép hoặc theo thỏa thuận công việc', 'Tự ý rời đi lâu', 'Không báo ai', 'Ngủ tại khu vực làm việc', 'A', 'An toàn và quy tắc làm việc'),
('Khi nhận dụng cụ của khách để vệ sinh, nên làm gì?', 'Sử dụng cẩn thận và đặt lại đúng chỗ', 'Mang về', 'Cho người khác mượn', 'Để ngoài hành lang', 'A', 'An toàn và quy tắc làm việc'),
('Khi không biết cách dùng thiết bị của khách, nên làm gì?', 'Hỏi hướng dẫn hoặc báo quản lý', 'Tự ý bấm thử tất cả nút', 'Tháo thiết bị', 'Bỏ mặc không báo', 'A', 'An toàn và quy tắc làm việc'),
('Khi thấy khu vực có nguy cơ mất an toàn, nên làm gì?', 'Tiếp tục làm bình thường', 'Báo ngay và hạn chế tiếp cận', 'Tự sửa mọi thứ', 'Bỏ qua', 'B', 'An toàn và quy tắc làm việc'),
('Khi có người đi qua khu vực đang lau, nên làm gì?', 'Không nói gì', 'Quát lớn', 'Nhắc lịch sự và hướng dẫn đi lối an toàn', 'Chặn họ bằng dụng cụ', 'C', 'An toàn và quy tắc làm việc'),
('Mục tiêu của vệ sinh nhà và văn phòng là gì?', 'Làm nhanh cho xong', 'Sạch, gọn, an toàn và không làm ảnh hưởng tài sản', 'Chỉ cần sàn sạch', 'Chỉ cần có mùi thơm', 'B', 'An toàn và quy tắc làm việc'),
('Khi phân loại rác tại văn phòng, nên làm gì?', 'Mang rác về', 'Bỏ tất cả vào một túi khi có quy định riêng', 'Để rác dưới bàn', 'Theo quy định phân loại rác của nơi làm việc', 'D', 'An toàn và quy tắc làm việc');

-- Random 10 câu mỗi lần làm bài
-- SELECT id, noi_dung, dap_an_a, dap_an_b, dap_an_c, dap_an_d
-- FROM cau_hoi
-- WHERE trang_thai = 'hoat_dong'
-- ORDER BY RAND()
-- LIMIT 10;

-- Công thức kết quả:
-- so_cau_dung >= 8 => ket_qua = 'dau'
-- so_cau_dung < 8  => ket_qua = 'rot'

-- Xem lịch sử làm bài:
-- SELECT uv.ho_ten, uv.so_dien_thoai, bl.so_cau_dung, bl.so_cau_sai, bl.diem, bl.ket_qua, bl.thoi_gian_nop
-- FROM bai_lam bl
-- JOIN ung_vien uv ON uv.id = bl.id_ung_vien
-- ORDER BY bl.id DESC;
