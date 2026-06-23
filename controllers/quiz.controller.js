const db = require('../config/database');

const PASS_SCORE = 8;
const QUESTION_LIMIT = 10;

exports.startQuiz = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const { ho_ten, so_dien_thoai, dia_chi, nam_sinh } = req.body;

    if (!ho_ten || !so_dien_thoai) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng nhập họ tên và số điện thoại'
      });
    }

    await connection.beginTransaction();

    const [ungVienResult] = await connection.query(
      `INSERT INTO ung_vien (ho_ten, so_dien_thoai, dia_chi, nam_sinh)
       VALUES (?, ?, ?, ?)`,
      [ho_ten.trim(), so_dien_thoai.trim(), dia_chi || null, nam_sinh || null]
    );

    const idUngVien = ungVienResult.insertId;

    const [baiLamResult] = await connection.query(
      `INSERT INTO bai_lam (id_ung_vien, tong_cau, trang_thai)
       VALUES (?, ?, 'dang_lam')`,
      [idUngVien, QUESTION_LIMIT]
    );

    const idBaiLam = baiLamResult.insertId;

    const [questions] = await connection.query(
      `SELECT id, noi_dung, dap_an_a, dap_an_b, dap_an_c, dap_an_d
       FROM cau_hoi
       WHERE trang_thai = 'hoat_dong'
       ORDER BY RAND()
       LIMIT ?`,
      [QUESTION_LIMIT]
    );

    if (questions.length < QUESTION_LIMIT) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Kho câu hỏi chưa đủ 10 câu hoạt động'
      });
    }

    const ids = questions.map(q => q.id);
    const placeholders = ids.map(() => '?').join(',');
    const [answerRows] = await connection.query(
      `SELECT id, dap_an_dung FROM cau_hoi WHERE id IN (${placeholders})`,
      ids
    );
    const answerMap = new Map(answerRows.map(row => [row.id, row.dap_an_dung]));

    for (let i = 0; i < questions.length; i++) {
      await connection.query(
        `INSERT INTO chi_tiet_bai_lam (id_bai_lam, id_cau_hoi, thu_tu, dap_an_dung)
         VALUES (?, ?, ?, ?)`,
        [idBaiLam, questions[i].id, i + 1, answerMap.get(questions[i].id)]
      );
    }

    await connection.commit();

    return res.json({
      success: true,
      message: 'Bắt đầu làm bài thành công',
      data: {
        id_bai_lam: idBaiLam,
        id_ung_vien: idUngVien,
        tong_cau: QUESTION_LIMIT,
        cau_hoi: questions.map((q, index) => ({
          thu_tu: index + 1,
          id: q.id,
          noi_dung: q.noi_dung,
          dap_an_a: q.dap_an_a,
          dap_an_b: q.dap_an_b,
          dap_an_c: q.dap_an_c,
          dap_an_d: q.dap_an_d
        }))
      }
    });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi khi bắt đầu làm bài'
    });
  } finally {
    connection.release();
  }
};

exports.submitQuiz = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const { id_bai_lam, dap_an } = req.body;

    if (!id_bai_lam || !Array.isArray(dap_an)) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu id bài làm hoặc danh sách đáp án'
      });
    }

    await connection.beginTransaction();

    const [baiLamRows] = await connection.query(
      `SELECT id, trang_thai FROM bai_lam WHERE id = ?`,
      [id_bai_lam]
    );

    if (baiLamRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Không tìm thấy bài làm' });
    }

    if (baiLamRows[0].trang_thai === 'da_nop') {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Bài này đã nộp rồi' });
    }

    const [detailRows] = await connection.query(
      `SELECT id, id_cau_hoi, dap_an_dung
       FROM chi_tiet_bai_lam
       WHERE id_bai_lam = ?`,
      [id_bai_lam]
    );

    const selectedMap = new Map(
      dap_an.map(item => [Number(item.id_cau_hoi), String(item.dap_an_chon || '').toUpperCase()])
    );

    let soCauDung = 0;

    for (const row of detailRows) {
      const dapAnChon = selectedMap.get(row.id_cau_hoi) || null;
      const laDung = dapAnChon === row.dap_an_dung ? 1 : 0;
      if (laDung) soCauDung++;

      await connection.query(
        `UPDATE chi_tiet_bai_lam
         SET dap_an_chon = ?, la_dung = ?
         WHERE id = ?`,
        [dapAnChon, laDung, row.id]
      );
    }

    const tongCau = detailRows.length;
    const soCauSai = tongCau - soCauDung;
    const diem = Number(((soCauDung / tongCau) * 10).toFixed(2));
    const ketQua = soCauDung >= PASS_SCORE ? 'dau' : 'rot';

    await connection.query(
      `UPDATE bai_lam
       SET so_cau_dung = ?, so_cau_sai = ?, diem = ?, ket_qua = ?,
           trang_thai = 'da_nop', thoi_gian_nop = NOW()
       WHERE id = ?`,
      [soCauDung, soCauSai, diem, ketQua, id_bai_lam]
    );

    await connection.commit();

    return res.json({
      success: true,
      message: 'Nộp bài thành công',
      data: {
        id_bai_lam,
        tong_cau: tongCau,
        so_cau_dung: soCauDung,
        so_cau_sai: soCauSai,
        diem,
        ket_qua: ketQua,
        ket_qua_text: ketQua === 'dau' ? 'ĐẬU' : 'RỚT'
      }
    });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    return res.status(500).json({ success: false, message: 'Lỗi khi nộp bài' });
  } finally {
    connection.release();
  }
};

exports.getResult = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT bl.*, uv.ho_ten, uv.so_dien_thoai, uv.dia_chi, uv.nam_sinh
       FROM bai_lam bl
       JOIN ung_vien uv ON uv.id = bl.id_ung_vien
       WHERE bl.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy kết quả' });
    }

    const [details] = await db.query(
      `SELECT ct.thu_tu, ch.noi_dung, ch.dap_an_a, ch.dap_an_b, ch.dap_an_c, ch.dap_an_d,
              ct.dap_an_chon, ct.dap_an_dung, ct.la_dung
       FROM chi_tiet_bai_lam ct
       JOIN cau_hoi ch ON ch.id = ct.id_cau_hoi
       WHERE ct.id_bai_lam = ?
       ORDER BY ct.thu_tu ASC`,
      [id]
    );

    return res.json({ success: true, data: { ...rows[0], chi_tiet: details } });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Lỗi khi lấy kết quả' });
  }
};

exports.getHistoryByPhone = async (req, res) => {
  try {
    const { so_dien_thoai } = req.params;

    const [rows] = await db.query(
      `SELECT uv.ho_ten, uv.so_dien_thoai, bl.id, bl.tong_cau, bl.so_cau_dung,
              bl.so_cau_sai, bl.diem, bl.ket_qua, bl.thoi_gian_nop
       FROM bai_lam bl
       JOIN ung_vien uv ON uv.id = bl.id_ung_vien
       WHERE uv.so_dien_thoai = ? AND bl.trang_thai = 'da_nop'
       ORDER BY bl.thoi_gian_nop DESC`,
      [so_dien_thoai]
    );

    return res.json({ success: true, data: rows });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Lỗi khi lấy lịch sử' });
  }
};
