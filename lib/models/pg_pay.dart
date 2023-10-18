
/// 결제 웹 페이지에 전달되는 데이터들
class PgPay {
  final String payType;
  final String userId;
  final String cstDiv;        // test / service
  final String pdCode;        // 상품코드
  final String pdSubDiv;      // 상품하위코드
  final String payAmount;

  final String orderCh;
  final String orderSn;
  final String period;
  final String nextPayDay;
  final String lgTid;
  final String lgCancelAmt;
  final String svcKeepYn;     //이용기간 보장 (Y:잔여기간 보장, N:종료)
  final String nextPayYn;     //정기 구독 유지 여부

  PgPay({
    this.payType = '',
    this.userId = '',
    this.cstDiv = '',
    this.pdCode = '',
    this.pdSubDiv = '',
    this.payAmount = '',
    this.orderCh = '',
    this.orderSn = '',
    this.period = '',
    this.nextPayDay = '',
    this.lgTid = '',
    this.lgCancelAmt = '',
    this.svcKeepYn = '',
    this.nextPayYn = '',
  });
}

