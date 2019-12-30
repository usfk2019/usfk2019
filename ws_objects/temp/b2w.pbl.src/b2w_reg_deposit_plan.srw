$PBExportHeader$b2w_reg_deposit_plan.srw
$PBExportComments$[kem] 채권보전료정책 등록
forward
global type b2w_reg_deposit_plan from w_a_reg_m
end type
end forward

global type b2w_reg_deposit_plan from w_a_reg_m
integer height = 1888
end type
global b2w_reg_deposit_plan b2w_reg_deposit_plan

on b2w_reg_deposit_plan.create
call super::create
end on

on b2w_reg_deposit_plan.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_amt, ls_month
decimal ldc_amt

//조회 시 상단 기준판매가, 할부개월수 범위 조회
ls_amt = String(dw_cond.Object.amt[1])
ldc_amt = dw_cond.Object.amt[1]
ls_month = String(dw_cond.Object.month[1])

If IsNull(ls_amt) Then ls_amt = ""
If IsNull(ls_month) Then ls_month = ""

ls_where = ""
If ls_amt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " ( toamt >= "+ ls_amt + ")"	
End If

If ls_month <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " quotamm = " + ls_month  + ""	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i, ll_rowcount, ll_cnt
String ls_fromdt, ls_framt, ls_toamt, ls_quotamm, ls_deposit, ls_sort
String ls_old_fromdt, ls_old_toamt, ls_old_framt, ls_old_quotamm, ls_seq
Datetime ldt_fromdt
dec ldc_framt, ldc_toamt, ldc_deposit, ldc_old_toamt, ldc_old_framt
integer li_i

ls_old_fromdt = ""

ll_rowcount = dw_detail.RowCount()
If ll_rowcount < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_rowcount
	ldt_fromdt = dw_detail.Object.fromdt[ll_i]
	ls_seq = String(dw_detail.Object.seq[ll_i])
	ls_fromdt = String(ldt_fromdt,'yyyymmdd')
	ldc_framt = dw_detail.Object.framt[ll_i]
	ldc_toamt = dw_detail.Object.toamt[ll_i]
	ls_quotamm = String(dw_detail.Object.quotamm[ll_i])
	ls_deposit = String(dw_detail.Object.deposit[ll_i])
	ls_framt = String(ldc_framt)
	ls_toamt = String(ldc_toamt)	

	If IsNull(ls_fromdt) Then ls_fromdt= ""
	If IsNull(ldc_framt) Then ls_framt= ""
	If IsNull(ldc_toamt) Then 
		ldc_toamt = 4294967295
		ls_toamt= ""
	End if
	If IsNull(ls_quotamm) Then ls_quotamm= ""
	If IsNull(ls_deposit) Then ls_deposit= ""
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title,"적용시작일")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("fromdt")
		Return -1
	End If	
	
	If ls_quotamm = "" Then 
		f_msg_usr_err(200, Title, "할부개월수")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("quotamm")
		Return -1
	End If

	
	If ls_framt = "" Then 
		f_msg_usr_err(200, Title, "판매가From")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("framt")
		Return -1
	End If
	
//	If ls_toamt = "" Then 
//		f_msg_usr_err(200, Title, "판매가To")
//		dw_detail.SetRow(ll_i)
//		dw_detail.ScrollToRow(ll_i)
//		dw_detail.SetColumn("toamt")
//		Return -1
//	End If

	If ls_toamt <> "" Then
		If ldc_framt > ldc_toamt Then
			f_msg_usr_err(9000, Title, "판매가From이  판매가To보다 큽니다.")
			dw_detail.SetRow(ll_i)
			dw_detail.ScrollToRow(ll_i)
			dw_detail.SetColumn("framt")
			Return -1
		End If
	End If
		
	If ls_deposit = "" Then 
		f_msg_usr_err(200, Title, "보증금")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("deposit")
		Return -1
	End If

	//이미 입력된 값 중 중복 범위 Check
	ll_cnt = 0
	select count(*)
	 into :ll_cnt
	 from depositmst
	where to_char(fromdt,'yyyymmdd') = :ls_fromdt
	 and quotamm = :ls_quotamm
	 and ( (framt <= :ls_framt and toamt >= :ls_framt) or
	        (framt <= :ls_toamt and toamt >= :ls_toamt) )
	 and seq <> :ls_seq;
			  
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "SELECT depositmst count")			
		Return -1
	End If	

	If ll_cnt > 0 Then
		f_msg_usr_err(221, Title, "판매가(from,to) 범위가 중복 되었습니다.")
		dw_detail.SetColumn("framt")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		Return -1
   End IF

	//새로 입력된 값도 check 해야 하므로 모든 행 중복범위를 check
	For li_i = 1 to ll_rowcount
		If li_i = ll_i Then continue
		ls_old_fromdt = String(dw_detail.Object.fromdt[li_i],'yyyymmdd')
		ls_old_quotamm = String(dw_detail.Object.quotamm[li_i])
		ldc_old_framt = dw_detail.Object.framt[li_i]
		ldc_old_toamt = dw_detail.Object.toamt[li_i]
		If isnull(ldc_old_toamt) Then ldc_old_toamt = 4294967295
		
		If ls_old_fromdt = ls_fromdt and ls_old_quotamm = ls_quotamm Then
			If (ldc_framt >= ldc_old_framt and ldc_framt <= ldc_old_toamt) or &
			   (ldc_toamt >= ldc_old_framt and ldc_toamt <= ldc_old_toamt)	Then
				f_msg_usr_err(221, Title, "판매가(from,to) 범위가 중복 되었습니다.")
				dw_detail.SetColumn("framt")
				dw_detail.SetRow(ll_i)
				dw_detail.ScrollToRow(ll_i)
				Return -1
			End if
		End if
	Next
	
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
		//dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
   End If
Next

dw_detail.SetRedraw(True)		

Return 0	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b2w_reg_deposit_plan
	Desc.	: 채권보전료정책 등록
	Ver 	: 1.0
	Date	: 2003.11.05
	Progrmaer: Kim Eun Mi(kem)
-------------------------------------------------------------------------*/
String ls_type, ls_desc

ls_type = fs_get_control("B0", "P105", ls_desc)

If ls_type = "KRW" Then
	dw_detail.object.framt.Format = "#,##0"
	dw_detail.object.toamt.Format = "#,##0"
	dw_detail.object.deposit.Format = "#,##0"
Else
	dw_detail.object.framt.Format = "#,##0.00"
	dw_detail.object.toamt.Format = "#,##0.00"
	dw_detail.object.deposit.Format = "#,##0.00"
End If

p_insert.TriggerEvent("ue_enable")


end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("amt")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;decimal ldc_seq
//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("fromdt")

//seq 가져 오기
Select seq_depositno.nextval
Into :ldc_seq
From dual;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT seq_depositno.nextval")			
	Return -1
End If	

//Log 정보
dw_detail.object.seq[al_insert_row] = ldc_seq
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b2w_reg_deposit_plan
integer x = 46
integer y = 60
integer width = 1847
integer height = 172
string dataobject = "b2dw_cnd_reg_deposit_plan"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b2w_reg_deposit_plan
integer x = 2277
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b2w_reg_deposit_plan
integer x = 2578
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within b2w_reg_deposit_plan
integer width = 1957
integer height = 244
end type

type p_delete from w_a_reg_m`p_delete within b2w_reg_deposit_plan
integer x = 384
integer y = 1672
end type

type p_insert from w_a_reg_m`p_insert within b2w_reg_deposit_plan
integer x = 91
integer y = 1672
end type

type p_save from w_a_reg_m`p_save within b2w_reg_deposit_plan
integer x = 677
integer y = 1672
end type

type dw_detail from w_a_reg_m`dw_detail within b2w_reg_deposit_plan
integer x = 23
integer y = 256
integer width = 3026
integer height = 1396
string dataobject = "b2dw_reg_deposit_plan"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b2w_reg_deposit_plan
integer x = 1298
integer y = 1672
end type

