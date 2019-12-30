$PBExportHeader$p0w_prc_move.srw
$PBExportComments$[victory] 카드이동처리
forward
global type p0w_prc_move from w_a_prc
end type
end forward

global type p0w_prc_move from w_a_prc
integer width = 2382
integer height = 1868
end type
global p0w_prc_move p0w_prc_move

type variables
Dec{2} ic_card_cnt, ic_amt
String is_lotno, is_movedt, is_contno_fr, is_contno_to, is_partner_fr, is_partner_to
String is_model, is_remark

end variables

on p0w_prc_move.create
call super::create
end on

on p0w_prc_move.destroy
call super::destroy
end on

event open;call super::open;dw_input.object.movedt[1] = Date(fdt_get_dbserver_now())
end event

event type integer ue_input();call super::ue_input;String ls_where
Long ll_rc

Dec{2} lc_card_cnt, lc_amt
String ls_lotno, ls_partner_fr, ls_partner_to, ls_contno_fr, ls_contno_to
String ls_model, ls_remark, ls_movedt
String ls_sysdate
Int li_contno_len


ls_partner_fr = Trim(dw_input.Object.outgo_partner[1])
If IsNull(ls_partner_fr) Then ls_partner_fr = ""

ls_partner_to = Trim(dw_input.Object.income_partner[1])
If IsNull(ls_partner_to) Then ls_partner_to = ""

ls_contno_fr = Trim(dw_input.Object.contno_fr[1])
If IsNull(ls_contno_fr) Then ls_contno_fr = ""

ls_contno_to = Trim(dw_input.Object.contno_to[1])
If IsNull(ls_contno_to) Then ls_contno_fr = ""

ls_lotno = Trim(dw_input.Object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

//카드 금액
lc_amt = dw_input.Object.price[1]
If IsNull(lc_amt) Then lc_amt = 0

ls_lotno = Trim(dw_input.Object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_remark = Trim(dw_input.Object.remark[1])
If IsNull(ls_remark) Then ls_remark = ""

ls_model = Trim(dw_input.Object.model[1])
If IsNull(ls_model) Then ls_model = ""

ls_movedt = String(dw_input.Object.movedt[1], 'yyyymmdd')


//***** 사용자 입력사항 검증 *****
If ls_model = "" Then
	f_msg_info(200, This.Title, "Model")
	dw_input.SetFocus()
	dw_input.SetColumn("model")
	Return -1
End If

If ls_contno_fr = "" and ls_lotno = "" Then
	f_msg_info(200, This.Title, "관리번호 혹은 Lot #를 입력하세요")
	dw_input.SetFocus()
	dw_input.SetColumn("contno_fr")
	Return -1
End If


If ls_partner_fr = "" Then
	f_msg_info(200, This.Title, "이동출고대리점")
	dw_input.SetFocus()
	dw_input.SetColumn("outgo_partner")
	Return -1
End If

If ls_partner_to = "" Then
	f_msg_info(200, This.Title, "이동입고대리점")
	dw_input.SetFocus()
	dw_input.SetColumn("income_partner")
	Return -1
End If


 If ls_movedt = "" Then
	f_msg_info(200, This.Title, "이동일자")
	dw_input.SetFocus()
	dw_input.SetColumn("movedt")
	Return -1
Else
   ls_sysdate = String(fdt_get_dbserver_now(), "yyyymmdd")
	If ls_movedt < ls_sysdate Then
		f_msg_info(100, This.Title, "이동일자 >= 현재일자")
		dw_input.SetFocus()
		dw_input.SetColumn("movedt")
		Return -1
	End If
End If
	
	
//***** 사용자 입력사항 Instance 변수에 저장 *****
ic_amt = lc_amt
is_lotno = ls_lotno
is_contno_fr = ls_contno_fr
is_contno_to = ls_contno_to
is_partner_fr = ls_partner_fr
is_partner_to = ls_partner_to
is_movedt = ls_movedt
is_remark = ls_remark
is_model = ls_model

Return 0

end event

event type integer ue_process();call super::ue_process;Integer	li_rc
String	ls_contno_first, ls_contno_last
Dec		ll_total


ll_total = 0 
//***** 처리부분 *****
p0c_dbmgr3 iu_db01

iu_db01 = Create p0c_dbmgr3

iu_db01.is_title = Title
iu_db01.is_caller = "Card Move"
iu_db01.ic_data[1] = ic_amt			
iu_db01.is_data[1] = is_model
iu_db01.is_data[2] = is_contno_fr
iu_db01.is_data[3] = is_contno_to
iu_db01.is_data[4] = is_lotno
iu_db01.is_data[5] = is_partner_fr
iu_db01.is_data[6] = is_partner_to
iu_db01.is_data[7] = is_movedt
iu_db01.is_data[8] = is_remark
iu_db01.uf_prc_db_02()

li_rc				 = iu_db01.ii_rc
ls_contno_first = iu_db01.is_data[1]
ls_contno_last  = iu_db01.is_data[2]

ll_total =  Long(iu_db01.ic_data[1])
w_msg_wait.wf_progress_init(0, ll_total, 0, 1)

Destroy iu_db01


//***** 결과 *****
If li_rc = -1 Then	//실패
	Return -1
ElseIf li_rc = 0 Then 					//성공
	is_msg_process = "이동출고 처리 " + String(ll_total) + "건" +"~r~n"  + &
						  "관리번호 From " + ls_contno_first + "~r~n" + &
						  "         To   " + ls_contno_last
	Return 0
ElseIf li_rc = -2 Then
   is_msg_process = "조건에 해당하는 카드가 없습니다."
	Return 0 
End If



end event

type p_ok from w_a_prc`p_ok within p0w_prc_move
integer x = 2030
integer y = 52
end type

type dw_input from w_a_prc`dw_input within p0w_prc_move
integer x = 50
integer y = 52
integer width = 1861
integer height = 824
string dataobject = "p0dw_cnd_prc_move"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::itemchanged;call super::itemchanged;DataWindowChild ldc_outgo_partner, ldc_model
Long ll_row
Dec ldc_amt
Dec{2} lc_amt

String ls_model, ls_partner, ls_filter

//카드 금액을 가져오기 위한 것
Choose Case dwo.name
	Case "outgo_partner" 
		If This.GetChild('outgo_partner', ldc_outgo_partner) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		//ll_row = ldc_outgo_partner.GetRow()
		//ls_partner = ldc_outgo_partner.GetItemString(ll_row, "partner")
		
		//Model 선택
		If This.GetChild('model', ldc_model) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ls_filter = "partner_pricemodel_partner = '" + data + "' "
	   ldc_model.SetFilter(ls_filter)			//Filter정함
		ldc_model.Filter()
		ldc_model.SetTransObject(SQLCA)
		ldc_model.Retrieve() 
		
	Case "model" 
		If This.GetChild('model', ldc_model) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row = ldc_model.GetRow()
		ldc_amt = ldc_model.GetItemNumber(ll_row, "price")
		This.object.price[1] = ldc_amt
		
	case "contno_fr"
		this.object.contno_to[1] = data
End Choose
end event

type dw_msg_time from w_a_prc`dw_msg_time within p0w_prc_move
integer y = 1456
integer width = 1911
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within p0w_prc_move
integer y = 948
integer width = 1911
integer height = 476
end type

type ln_up from w_a_prc`ln_up within p0w_prc_move
integer beginy = 928
integer endy = 928
end type

type ln_down from w_a_prc`ln_down within p0w_prc_move
integer beginy = 1752
integer endy = 1752
end type

type p_close from w_a_prc`p_close within p0w_prc_move
integer x = 2030
integer y = 180
end type

type gb_cond from w_a_prc`gb_cond within p0w_prc_move
integer width = 1911
integer height = 896
end type

