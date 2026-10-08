const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// Contoh: "October 2026". Tanggal kosong menghasilkan "-".
String monthYear(DateTime? date) {
  if (date == null) return '-';
  return '${_months[date.month - 1]} ${date.year}';
}
