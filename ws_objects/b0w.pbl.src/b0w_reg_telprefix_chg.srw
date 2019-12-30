$PBExportHeader$b0w_reg_telprefix_chg.srw
$PBExportComments$[kjm]번호 보정 등록
forward
global type b0w_reg_telprefix_chg from w_a_reg_m
end type
end forward

global type b0w_reg_telprefix_chg from w_a_reg_m
integer width = 3182
integer height = 1920
end type
global b0w_reg_telprefix_chg b0w_reg_telprefix_chg

type variables
String is_title

end variables

forward prototypes
end prototypes

on b0w_reg_telprefix_chg.create
call super::create
end on

on b0w_reg_telprefix_chg.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b0w_reg_telprefix_chg
	Desc. : 번호보정등록
	Date : 2004.08.12
	Auth : Kwon Jung Min
------------------------------------------------------------------------*/
dw_cond.object.type[1] = 'S'	//발신

dw_cond.SetColumn('telprefix')

is_title = title

//p_insert.TriggerEvent("ue_enable")
end event

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_telprefix,	 ls_type

ls_type = dw_cond.object.type[1]

IF IsNull(ls_type) THEN ls_type = ""

IF ls_type = "" THEN
//	messagebox('a', 'a')
	f_msg_info(200, is_title,"작업선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("type")   
	Return	
ELSE
	IF ls_type = 'S' THEN
		dw_detail.object.telprefix_t.text = '발신지 Prefix'
	ELSE
		dw_detail.object.telprefix_t.text = '착신지 Prefix'		
	END IF
END IF

ls_telprefix	= Trim( dw_cond.Object.telprefix[1] )

IF( IsNull(ls_telprefix) ) THEN ls_telprefix = ""

//Dynamic SQL
IF ls_telprefix <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "TELPREFIX LIKE '" + ls_telprefix + "%'"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve(ls_type)

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, This.Title, "")
END IF

p_insert.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0
end event

event type integer ue_save();String ls_priceplan
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

// 수정도 안한상태에서 저장루틴을 타면 중복 check를 하기때문에 수정이 없으면 저장 루틴 안탐
//IF dw_detail.ModifiedCount() + dw_detail.DeletedCount() < 1 THEN RETURN -1	

If This.Trigger Event ue_extra_save() < 0 Then
	Return LI_ERROR
End If

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else

	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End If

//cb_load.Enabled = False
Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_tot_row,	ll_dup_chk
String ls_telprefix,	ls_fromdt,	ls_todt,		ls_chgvalue,	ls_type,	ls_sort
Boolean lb_dup

// Prefix별 적용시작일, 적용종료일 check variable
Long ll_chk_row1, ll_chk_row2,	ll_chk_row  
String ls_telprefix1,	ls_telprefix2,	ls_fromdt1,	ls_fromdt2,	ls_todt1,	ls_todt2

ll_tot_row = dw_detail.RowCount()

// 필수 입력 사항 check -> Prefix, 적용시작일
FOR ll_row = 1 TO ll_tot_row
	ls_type = dw_detail.object.type[ll_row]
	ls_telprefix = dw_detail.Object.telprefix[ll_row]
	ls_fromdt = String(dw_detail.Object.fromdt[ll_row],'yyyymmdd')
	ls_todt = String(dw_detail.Object.todt[ll_row],'yyyymmdd')
	ls_chgvalue = dw_detail.Object.chgvalue[ll_row]
	IF IsNull(ls_telprefix) THEN ls_telprefix = ""
	IF IsNull(ls_fromdt) THEN ls_fromdt = ""	
	IF IsNull(ls_todt) THEN ls_todt = ""	
	IF IsNull(ls_chgvalue) THEN ls_chgvalue = ""		
	
	If ls_telprefix = "" Then
		IF ls_type = 'S' THEN
			f_msg_usr_err(200, Title, "발신지Prefix")
		ELSE
			f_msg_usr_err(200, Title, "착신지Prefix")
		END IF
		
		dw_detail.SetColumn("telprefix")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If

	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetColumn("fromdt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If

	If ls_chgvalue <> "" Then
		dw_detail.object.chgvalue[ll_row] = Trim(ls_chgvalue)
	End If
	
//적용종료일 체크
	If ls_todt <> "" Then
		If ls_fromdt > ls_todt Then
			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
			dw_detail.setColumn("todt")
			dw_detail.setRow(ll_row)
			dw_detail.scrollToRow(ll_row)
			dw_detail.SetRedraw(True)
			Return -2
		End If
	End If		
NEXT

dw_detail.SetRedraw(False)
ls_sort = "telprefix, string(fromdt, 'yyyymmdd')"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

//	 발신지Prefix별 적용시작일 적용종료일 겹치지 않도록 check
FOR ll_chk_row1 = 1 TO dw_detail.RowCount()
	ls_telprefix1 = dw_detail.Object.telprefix[ll_chk_row1]
	ls_fromdt1 = String(dw_detail.Object.fromdt[ll_chk_row1],'yyyymmdd')
	ls_todt1 = String(dw_detail.Object.todt[ll_chk_row1],'yyyymmdd')
	IF IsNull(ls_todt1) OR ls_todt1 = "" THEN ls_todt1 = '99991231'
	
	FOR ll_chk_row2 = dw_detail.RowCount() TO ll_chk_row1 - 1 Step -1
		
		IF ll_chk_row1 = ll_chk_row2 THEN EXIT
		
		ls_telprefix2 = dw_detail.object.telprefix[ll_chk_row2]
		ls_fromdt2 = String(dw_detail.Object.fromdt[ll_chk_row2],'yyyymmdd')
		ls_todt2 = String(dw_detail.Object.todt[ll_chk_row2],'yyyymmdd')
		IF IsNull(ls_todt1) OR ls_todt1 = "" THEN ls_todt1 = '99991231'

		IF ls_telprefix1 = ls_telprefix2 THEN
			If ls_todt1 >= ls_fromdt2 Then
				IF ls_type = 'S' THEN
					f_msg_info(9000, Title, "같은 발신지Prefix[ "+ls_telprefix1+" ]에 대해 적용기간이 중복됩니다.")									
				ELSE
					f_msg_info(9000, Title, "같은 착신지Prefix[ "+ls_telprefix1+" ]에 대해 적용기간이 중복됩니다.")					
				END IF
				
				dw_detail.ScrollToRow(ll_chk_row2)
				dw_detail.SetColumn('telprefix')
				dw_detail.SetFocus()

				lb_dup = TRUE
			End If
		END IF		
	NEXT
	
	If dw_detail.GetItemStatus(ll_chk_row1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_chk_row1] = gs_user_id
		dw_detail.object.updtdt[ll_chk_row1] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_chk_row1] = gs_pgm_id[1]
	End If

NEXT

IF lb_dup THEN RETURN -1

Return 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
String ls_type

ls_type = dw_cond.object.type[1]

IF IsNull(ls_type) THEN ls_type = ""

IF ls_type = "" THEN
	f_msg_info(200, is_title,"작업선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("type")   
	Return -1
ELSE
	
	IF ls_type = 'S' THEN
		dw_detail.object.telprefix_t.text = '발신지 Prefix'
	ELSE
		dw_detail.object.telprefix_t.text = '착신지 Prefix'
	END IF

	ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)
	
	dw_detail.ScrollToRow(ll_row)
	dw_detail.SetRow(ll_row)
	dw_detail.SetColumn('telprefix')
	dw_detail.SetFocus()
	
	dw_detail.object.type[ll_row] = ls_type

END IF

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if


p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//p_insert.TriggerEvent('ue_enable')

dw_cond.AcceptText()

dw_cond.object.type[1] = 'S'		//발신지에 focus

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_telprefix_chg
integer x = 64
integer width = 1755
integer height = 220
integer taborder = 10
string dataobject = "b0dw_cnd_telprefix_chg"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_telprefix_chg
integer x = 2007
integer y = 72
end type

type p_close from w_a_reg_m`p_close within b0w_reg_telprefix_chg
integer x = 2313
integer y = 72
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_telprefix_chg
integer width = 1842
integer height = 308
integer taborder = 30
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_telprefix_chg
integer y = 1684
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_telprefix_chg
integer y = 1684
end type

type p_save from w_a_reg_m`p_save within b0w_reg_telprefix_chg
integer y = 1684
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_telprefix_chg
integer y = 332
integer width = 3099
integer height = 1320
integer taborder = 20
string dataobject = "b0dw_reg_telprefix_chg"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_telprefix_cond			// 조회조건에 있는 prefix
String ls_telprefix,	ls_type			// dw_detail에 있는 prefix

Integer li_len

ls_telprefix_cond = dw_cond.object.telprefix[1]
IF IsNull(ls_telprefix_cond) THEN ls_telprefix_cond = ""

ls_telprefix = Trim(This.object.telprefix[row])
ls_type = Trim(This.object.type[row])
CHOOSE CASE dwo.name
	CASE 'telprefix'
		IF ls_telprefix_cond <> "" THEN
			li_len = LenA(ls_telprefix_cond)
			IF LeftA(ls_telprefix,li_len) <> ls_telprefix_cond THEN
				IF ls_type = 'S' THEN
					f_msg_usr_err(9000, Title, "발신지 prefix가 ["+ ls_telprefix_cond +"] 으로 시작해야 합니다.")
				ELSE
					f_msg_usr_err(9000, Title, "착신지 prefix가 ["+ ls_telprefix_cond +"] 으로 시작해야 합니다.")					
				END IF

//				This.SetFocus()
				This.SetColumn('telprefix')
				RETURN -1
				
			END IF
		END IF		
END CHOOSE
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_telprefix_chg
integer y = 1684
end type

event p_reset::ue_enable();call super::ue_enable;//messagebox('a', 's')
end event

