$PBExportHeader$p0w_reg_io.srw
$PBExportComments$[chooys]선불카드수불작업 Window
forward
global type p0w_reg_io from w_a_reg_m_m3
end type
type p_saveas from u_p_saveas within p0w_reg_io
end type
end forward

global type p0w_reg_io from w_a_reg_m_m3
event ue_saveas ( )
p_saveas p_saveas
end type
global p0w_reg_io p0w_reg_io

type variables
String is_cardstatus_issue
end variables

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

on p0w_reg_io.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on p0w_reg_io.destroy
call super::destroy
destroy(this.p_saveas)
end on

event resize;call super::resize;//SaveAs 버튼 처리
p_saveas.Y = p_save.Y

end event

event ue_ok();CALL w_a_condition::ue_ok

Long ll_row
String ls_where
String ls_issuedt_from, ls_issuedt_to
String ls_issuestat
String ls_lotno
String ls_model

Long li_ret

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = -1 
			li_ret = Event ue_save()
			If Isnull( li_ret ) or li_ret < 0 then return
		CASE 2

		CASE ELSE
			Return 
	END CHOOSE
		
end If

//Event ue_ok_after()

//dw_master.event ue_select()

ls_issuedt_from = String(dw_cond.Object.issuedt_from[1],"YYYYMMDD")
ls_issuedt_to = String(dw_cond.Object.issuedt_to[1],"YYYYMMDD")
ls_issuestat = Trim(dw_cond.Object.status[1])
ls_lotno = Trim(dw_cond.Object.lotno[1])
ls_model = Trim(dw_cond.Object.pricemodel[1])

If IsNull(ls_issuedt_from) Then ls_issuedt_from = ""
If IsNull(ls_issuedt_to) Then ls_issuedt_to = ""
If IsNull(ls_issuestat) Then ls_issuestat = ""
If IsNull(ls_lotno) Then ls_lotno = ""
If IsNull(ls_model) Then ls_model = ""

ls_where = ""

If ls_issuedt_from <> "" then
	If ls_where <> "" then ls_where += " and "
	ls_where += "to_char(issuedt,'YYYYMMDD') >= '" + ls_issuedt_from + "' "
end If	

If ls_issuedt_to <> "" then
	If ls_where <> "" then ls_where += " and "
	ls_where += "to_char(issuedt,'YYYYMMDD') <= '" + ls_issuedt_to + "' "
end If	

If ls_issuestat <> "" then
	If ls_where <> "" then ls_where += " and "
	ls_where += "issuestat = '" + ls_issuestat + "' "
end If	

If ls_lotno <> "" then
	If ls_where <> "" then ls_where += " and "
	ls_where += "lotno = '" + ls_lotno + "' "
end If	

If ls_model <> "" then
	If ls_where <> "" then ls_where += " and "
	ls_where += "pricemodel = '" + ls_model + "' "
end If	

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
IF ll_row > 0 THEN
	p_reset.TriggerEvent("ue_enable")	
	dw_cond.Enabled = FALSE
ELSE
	IF ll_row = 0 THEN
		f_msg_info(1000, This.Title, "")
	ELSEIF ll_row < 0 THEN
		f_msg_usr_err(2100, This.Title, "Function Failed")
	END IF

	dw_cond.SetFocus()
END IF
end event

event ue_extra_save(ref integer ai_return);Int li_cnt, i
Long ll_rows
String ls_issueseq
String ls_issuestat
String ls_code_issuestat[]
String ls_code_sale_flag[]
String ls_desc
String ls_sale_flag
String ls_indt
Date ld_null
Boolean lb_in

SetNull(ld_null)

ls_issueseq = String(dw_detail2.object.issueseq[1])
IF IsNULL(ls_issueseq) THEN ls_issueseq = ""
ls_issuestat = Trim(dw_detail2.object.issuestat[1])
IF IsNULL(ls_issuestat) THEN ls_issuestat = ""
ls_sale_flag = Trim(dw_detail2.object.sale_flag[1])
IF IsNULL(ls_sale_flag) THEN ls_sale_flag = ""
ls_indt = String(dw_detail2.object.indt[1],"YYYYMMDD")
IF IsNULL(ls_indt) THEN ls_indt = ""


IF ls_issueseq = "" THEN
	f_msg_usr_err(200, Title, "IssueSeq")
	dw_detail2.SetFocus()
	ai_return = -1
	Return
END IF

IF ls_issuestat = "" THEN
	f_msg_usr_err(200, Title, "발행상태")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("issuestat")
	ai_return = -1
	Return
END IF

IF ls_sale_flag = "" THEN
	f_msg_usr_err(200, Title, "재고상태")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("sale_flag")
	ai_return = -1
	Return
END IF

//모든 카드가 발행상태 일때만 수불관리 저장가능.
SELECT COUNT(*)
INTO :ll_rows
FROM p_cardmst
WHERE issuestat <> :is_cardstatus_issue
AND issueseq = :ls_issueseq;

IF ll_rows > 0 THEN
	ai_return = -1
	RETURN
END IF

//입고여부 체크
li_cnt = fi_cut_string(fs_get_control('P0','P111',ls_desc),";",ls_code_issuestat)

lb_in = False

FOR i=1 TO li_cnt
	IF ls_issuestat = ls_code_issuestat[i] THEN
		lb_in = TRUE		
		EXIT
	END IF
NEXT

//입고이면 입고일 필수
IF lb_in THEN
	IF ls_indt = "" THEN
		f_msg_usr_err(200, Title, "입고일")
		dw_detail2.SetFocus()
		dw_detail2.SetColumn("indt")
		ai_return = -1
		Return
	END IF
ELSE
	dw_detail2.object.indt[1] = ld_null
END IF



ai_return = 0

end event

event open;call super::open;Int li_tmp
String ls_cardstatus[]
String ls_desc

li_tmp = fi_cut_string(fs_get_control('P0','P101',ls_desc),";",ls_cardstatus)

IF li_tmp < 1 THEN
	MessageBox("System Control","카드상태 코드없음(P0:P101)")
	RETURN -1
ELSE	
	is_cardstatus_issue = ls_cardstatus[1]
END IF

end event

event type integer ue_save();//Inheritance

Int li_return

ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

This.Trigger Event ue_extra_save(li_return)

If li_return < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

//If dw_detail.Update() < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return -1
//	End If
//	f_msg_info(3010,This.Title,"Save")
//	return -1
//end If

If dw_detail2.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail2.SetFocus()
		return -1
	End If
	f_msg_info(3010,This.Title,"Save")
	return -1
end If

// 저장후 commit 전에 할일 
li_return = 1
Event ue_save_after( li_return )
If li_return < 0 then
	f_msg_info(3010,This.Title,"Save")
	rollback ;
	return -1
End If


//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then

	dw_detail.SetFocus()
	return -1
End If
//f_msg_info(3000,This.Title,"Save")
//
//
//ii_error_chk = 0
//return 1

//Inheritance

Dec ldc_issueseq
String ls_issuestat
String ls_card_maker
String ls_orderdt
String ls_indt
String ls_sale_flag
String ls_remark
Int li_rc


ldc_issueseq = dw_detail2.object.issueseq[1]
ls_issuestat = Trim(dw_detail2.object.issuestat[1])
IF IsNULL(ls_issuestat) THEN ls_issuestat = ""
ls_card_maker = Trim(dw_detail2.object.card_maker[1])
IF IsNULL(ls_card_maker) THEN ls_card_maker = ""
ls_orderdt = String(dw_detail2.object.orderdt[1],"YYYYMMDD")
IF IsNULL(ls_orderdt) THEN ls_orderdt = ""
ls_indt = String(dw_detail2.object.indt[1],"YYYYMMDD")
IF IsNULL(ls_indt) THEN ls_indt = ""
ls_sale_flag = Trim(dw_detail2.object.sale_flag[1])
IF IsNULL(ls_sale_flag) THEN ls_sale_flag = ""
ls_remark = Trim(dw_detail2.object.remark[1])
IF IsNULL(ls_remark) THEN ls_remark = ""

//***** 처리부분 *****
p0c_dbmgr4 iu_db

iu_db = Create p0c_dbmgr4

iu_db.is_title = Title

iu_db.ic_data[1] = ldc_issueseq		//발행Seq.
iu_db.is_data[1] = ls_issuestat		//발행상태
iu_db.is_data[2] = ls_card_maker		//카드제조사
iu_db.is_data[3] = ls_orderdt			//주문일자
iu_db.is_data[4] = ls_indt				//입고일자
iu_db.is_data[5] = ls_sale_flag		//재고상태
iu_db.is_data[6] = ls_remark			//비고

iu_db.is_caller = "p0w_reg_io%save"
iu_db.uf_prc_db_01()


li_rc	= iu_db.ii_rc

Destroy iu_db


//***** 결과 *****
If li_rc < 0 Then	//실패
	Return -1
Else					//성공
	f_msg_info(3000,This.Title,"Save")
	
	Long ll_selected_row 
	//Integer li_return, li_ret

	ll_selected_row = dw_master.getrow()
	dw_detail.Event ue_retrieve(ll_selected_row,li_return)
	
	ii_error_chk = 0
	return 1
End If


end event

type dw_cond from w_a_reg_m_m3`dw_cond within p0w_reg_io
integer height = 212
string dataobject = "p0dw_cnd_reg_io"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m3`p_ok within p0w_reg_io
end type

type p_close from w_a_reg_m_m3`p_close within p0w_reg_io
end type

type gb_cond from w_a_reg_m_m3`gb_cond within p0w_reg_io
end type

type dw_master from w_a_reg_m_m3`dw_master within p0w_reg_io
string dataobject = "p0dw_inq_reg_io"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.issueseq_t
uf_init(ldwo_SORT)

end event

event dw_master::ue_select();	
Long ll_selected_row 
Integer li_return, li_ret


ll_selected_row = GetSelectedRow( 0 )


dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If
	
dw_detail.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If




end event

event dw_master::retrieveend;call super::retrieveend;IF rowcount > 0 THEN
	Event ue_select()	
END IF

end event

type dw_detail from w_a_reg_m_m3`dw_detail within p0w_reg_io
integer y = 1032
integer height = 576
string dataobject = "p0dw_inq_reg_io_p_card"
end type

event dw_detail::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_where, ls_desc, ls_issuestat
Dec ldc_issueseq
Long i
int li_count
String ls_issuestat_not[]

if al_select_row > 0 then
	ldc_issueseq = dw_master.Object.issueseq[ al_select_row ]
else 
	ldc_issueseq = 0
End If

ls_where = "issueseq = '" + String(ldc_issueseq) + "' "

is_where = ls_where
ai_return = This.Retrieve()

//if al_select_row > 0 then
//	ls_issuestat = dw_master.Object.issuestat[ al_select_row ]
//END IF
//li_count = fi_cut_string(fs_get_control('P0','P113',ls_desc),";",ls_issuestat_not)	
//
// 발행(미입고) 인 경우만 제작/입고 활성화
//IF ls_issuestat = ls_issuestat_not[1] THEN
		
	//모든 카드가 발행인지 체크 -> 발행상태가 아닌 카드가 있으면 Save 불가
	FOR i=1 TO ai_return
		IF dw_detail.object.status[i] <> is_cardstatus_issue THEN
			dw_detail2.Enabled = False
			p_save.TriggerEvent("ue_disable")
			RETURN
		END IF
	NEXT
	
	dw_detail2.Enabled = True
	p_save.TriggerEvent("ue_enable")
//ELSE
//	dw_detail2.Enabled = False
//	p_save.TriggerEvent("ue_disable")
//	RETURN 
//END IF


end event

type p_insert from w_a_reg_m_m3`p_insert within p0w_reg_io
boolean visible = false
end type

type p_delete from w_a_reg_m_m3`p_delete within p0w_reg_io
boolean visible = false
end type

type p_save from w_a_reg_m_m3`p_save within p0w_reg_io
end type

event p_save::clicked;call super::clicked;//
end event

type p_reset from w_a_reg_m_m3`p_reset within p0w_reg_io
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within p0w_reg_io
integer height = 276
string dataobject = "p0dw_reg_reg_io"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail2::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_where
Dec ldc_issueseq

String ls_issuestat
String ls_code_issuestat[], ls_issuestat_not[]
String ls_desc
Int li_cnt,li_count
Long i
Boolean ib_in

if al_select_row > 0 then
	ldc_issueseq = dw_master.Object.issueseq[ al_select_row ]
else 
	ldc_issueseq = 0
End If

ls_where = "issueseq = '" + String(ldc_issueseq) + "' "

is_where = ls_where
ai_return = This.Retrieve()

IF ai_return = 1 THEN
	
	ls_issuestat = dw_master.Object.issuestat[ al_select_row ]
	
	//입고이면 재고상태 체크
	li_cnt = fi_cut_string(fs_get_control('P0','P111',ls_desc),";",ls_code_issuestat)

	ib_in = False
	
	FOR i=1 TO li_cnt
		IF ls_issuestat = ls_code_issuestat[i] THEN
			ib_in = True
			Exit
		END IF
	NEXT 
	
	//발행상태가 입고이면 재고(1)
	IF ib_in THEN
		This.Object.sale_flag[1] = "1"
	
	//발행상태가 입고가 아니면 미입고(2)
	ELSE
		This.Object.sale_flag[1] = "2"
	END IF
		
END IF

//저장한거로 인식하게 함.
For i = 1 To dw_detail2.RowCount()
	dw_detail2.SetitemStatus(i, 0, Primary!, NotModified!)
Next  
end event

event dw_detail2::itemchanged;call super::itemchanged;String ls_issuestat
String ls_code_issuestat[]
String ls_desc
Int li_cnt, i
Boolean ib_in

//입고이면 재고상태 체크
li_cnt = fi_cut_string(fs_get_control('P0','P111',ls_desc),";",ls_code_issuestat)

Choose Case dwo.name
	Case "issuestat"
		ls_issuestat = data
		
		ib_in = False
		
		FOR i=1 TO li_cnt
			IF ls_issuestat = ls_code_issuestat[i] THEN
				ib_in = True
				Exit
			END IF
		NEXT 
		
		//발행상태가 입고이면 재고(1)
		IF ib_in THEN
			This.Object.sale_flag[1] = "1"
		
		//발행상태가 입고가 아니면 미입고(2)
		ELSE
			This.Object.sale_flag[1] = "2"
		END IF

End Choose
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within p0w_reg_io
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within p0w_reg_io
end type

type p_saveas from u_p_saveas within p0w_reg_io
integer x = 942
integer y = 1648
boolean bringtotop = true
end type

