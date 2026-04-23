Application Architecture

Dự án được xây dựng dựa trên kiến trúc Layered Architecture (Kiến trúc phân lớp) kết hợp với Provider Pattern để quản lý trạng thái. Cấu trúc này giúp tách biệt hoàn toàn giữa logic tính toán (Business Logic) và giao diện (UI), đảm bảo tính dễ bảo trì và mở rộng.

1. High-Level Diagram

Sơ đồ luồng dữ liệu của ứng dụng:

User Interaction (UI) -> Provider (State Management) -> Logic Engine / Storage Service

2. Layer Definitions

📂 Models Layer

Chứa các thực thể dữ liệu (Data Entities) của ứng dụng.

-	CalculatorSettings: Lưu trữ cấu hình người dùng (Precision, Haptic, Theme...).
-	CalculationHistory: Cấu trúc của một bản ghi lịch sử.
-	CalculatorMode: Định nghĩa các hằng số cho chế độ (Basic, Scientific, Programmer).

📂 Providers Layer (The "Brain")

Đây là tầng trung tâm điều phối mọi hoạt động của ứng dụng.
-	CalculatorProvider: Xử lý logic tính toán, phân tích biểu thức (Regex), xử lý hệ cơ số và quản lý bộ nhớ (Memory).
-	ThemeProvider: Điều khiển trạng thái giao diện (Light/Dark/System mode).
-	HistoryProvider: Quản lý danh sách lịch sử và các thao tác thêm/xóa/giới hạn bản ghi.

📂 Services Layer

Chứa các dịch vụ ngoại vi và truy cập dữ liệu cứng.
-	StorageService: Sử dụng shared_preferences để lưu trữ dữ liệu bền vững xuống bộ nhớ điện thoại (Persistence), giúp dữ liệu không bị mất khi đóng app.

📂 Widgets & Screens Layer (UI)

Tầng hiển thị, chỉ tập trung vào việc render giao diện dựa trên dữ liệu từ Provider.

-	DisplayArea: Khu vực hiển thị số liệu với các hiệu ứng Animation (Fade, Shake) và cử chỉ (Swipe, Pinch).
-	ButtonGrid: Lưới nút bấm linh hoạt, tự động thay đổi theo chế độ hiện tại.
-	SettingsScreen & HistoryScreen: Các màn hình tính năng phụ trợ.

📂 Utils & Constants

-	Constants: Lưu trữ các mã màu, kiểu chữ và cấu hình giao diện dùng chung.
-	Expression Parser: Tích hợp thư viện math_expressions để giải quyết các phép tính phức tạp.

3. Design Patterns Used
-	Observer Pattern (Provider): Các Widget tự động "lắng nghe" và cập nhật khi dữ liệu trong Provider thay đổi thông qua notifyListeners().
-	Singleton Pattern: Áp dụng cho các lớp Service để đảm bảo chỉ có một instance duy nhất quản lý bộ nhớ.
-	Command Pattern: Mỗi nút bấm trên Calculator đóng vai trò như một command gửi chỉ thị đến CalculatorProvider.
4. Logic Processing Flow (Implicit Multiplication & 2nd Mode)

Ứng dụng sử dụng kỹ thuật Regex Pre-processing (Tiền xử lý bằng biểu thức chính quy) để làm sạch và chuẩn hóa biểu thức trước khi đưa vào bộ thư viện tính toán:

1.	Nhận chuỗi từ người dùng (VD: 2π).
2.	Regex chèn dấu nhân ngầm: 2*π.
3.	Regex dịch hàm lượng giác dựa trên AngleMode (DEG/RAD).
4.	Tính toán và trả về kết quả định dạng theo decimalPrecision.
 