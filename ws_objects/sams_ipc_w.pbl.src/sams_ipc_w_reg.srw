$PBExportHeader$sams_ipc_w_reg.srw
$PBExportComments$[hcjung] IPC 카드 연동 조회 및 충전 화면
forward
global type sams_ipc_w_reg from w_a_reg_m
end type
end forward

global type sams_ipc_w_reg from w_a_reg_m
integer width = 3534
integer height = 1852
end type
global sams_ipc_w_reg sams_ipc_w_reg

type variables
STring 		is_emp_grp, &
is_customerid, &
is_caldt , &
is_userid , &
is_pgm_id , is_basecod, is_control, &
is_method[], &
is_trcod[]

dec{2} 			idc_total, idc_receive, idc_change
end variables

forward prototypes
public subroutine wf_set_total ()
end prototypes

public subroutine wf_set_total ();dec{2} ldc_TOTAL, ldc_receive, ldc_change, &
			ldc_tot1, ldc_tot2, ldc_tot3

ldc_total = 0
ldc_tot1 = 0
ldc_tot2 = 0
ldc_tot3 = 0

IF dw_detail.RowCount() > 0 THEN
	ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund")
END IF
dw_cond.Object.total[1] 		= ldc_total

//
//F_INIT_DSP(2, "", String(ldc_total))
//
return 
end subroutine

on sams_ipc_w_reg.create
call super::create
end on

on sams_ipc_w_reg.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String 	ls_where, &
		 	ls_customerid, ls_memberid, 	ls_bil_fromdt
Long 		ll_row
date 		ldt_refunddt

ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_memberid    = Trim(dw_cond.object.memberid[1])
//ls_bil_fromdt 	= mid(String(dw_cond.object.bil_fromdt[1], 'yyyymmdd'),7,2)
ls_bil_fromdt 	= Trim(dw_cond.object.bil_fromdt[1])

If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_memberid) 		Then ls_memberid 		= ""
If IsNull(ls_bil_fromdt) 	Then ls_bil_fromdt 	= ""


ls_where = ""

//CUSTOMERID
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cont.customerid = '" + ls_customerid + "' "
End If

//Member ID
If ls_memberid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cust.memberid = '" + ls_memberid + "' "
End If

//bil_fromdt
If ls_bil_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "TO_CHAR( cont.BIL_FROMDT,'DD') = '" + ls_bil_fromdt + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
		dw_cond.SetColumn("customerid")	
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

event type integer ue_extra_save();Long 		ll_row, 		i, 	ll_seq, 		ll_tmp
Dec{2} 	lc_amt[], 	lc_totalamt,		ldc_tmp
Dec 		lc_saleamt
Integer 	li_rc, 		li_rtn,				li_tmp
String 	ls_customerid, 		ls_memberid, ls_bil_fromdt

sams_dbmgr_01	lu_dbmgr
dw_cond.AcceptText()

idc_total 		= 0
ls_customerid 	= trim(dw_cond.Object.customerid[1])
ls_MEMBERid 	= trim(dw_cond.Object.memberid[1])
ls_bil_fromdt  = String(dw_cond.Object.bil_fromdt[1],'yyyymmdd')

IF IsNUll(ls_bil_fromdt) 		then ls_bil_fromdt 	= ''
IF IsNUll(ls_customerid) 	then ls_customerid 	= ''
IF IsNUll(ls_memberid) 		then ls_memberid 		= ''

dw_cond.Accepttext()

//저장
lu_dbmgr = Create sams_dbmgr_01

lu_dbmgr.is_caller 	= "sams_ipc"
lu_dbmgr.is_title 	= Title
lu_dbmgr.idw_data[1] = dw_cond 	//조건
lu_dbmgr.idw_data[2] = dw_detail //조건

lu_dbmgr.is_data[1] 	= ls_customerid
lu_dbmgr.is_data[2] 	= ls_memberid    //memberid 
lu_dbmgr.is_data[3] 	= ls_bil_fromdt //bil_fromdt
lu_dbmgr.is_data[4] 	= GS_USER_ID     //Operator
lu_dbmgr.is_data[5] 	= gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[6]	= "IPC" //PGM_ID
lu_dbmgr.is_data[7]  = ""

lu_dbmgr.uf_prc_db_01()
//위 함수에서 이미 commit 한 상태임.
li_rc = lu_dbmgr.ii_rc
Destroy lu_dbmgr

If li_rc = -1 Or li_rc = -2 Then
	Return -1
End If

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_cond.SetFocus()
dw_detail.Reset()
Return 0
end event

event type integer ue_reset();call super::ue_reset;String ls_temp, ls_ref_desc
//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_method[])

//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_trcod[])

//초기화
dw_cond.ReSet()
dw_cond.InsertRow(0)

//dw_cond.object.bil_fromdt[1] 				= fd_date_next(Date(fdt_get_dbserver_now()),1)

dw_cond.SetFocus()
dw_cond.SetColumn("customerid")

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	sams_ipc_w_reg
	Desc.	: 	IPC 카드 일괄 충전
	Ver.	:	1.0
	Date	: 	2008.02.04
	Programer : Jung Hee Chan [ hcjung ]
--------------------------------------------------------------------------*/

This.Trigger Event ue_reset() 



end event

event type integer ue_save();Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
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
This.Trigger Event ue_reset() 
	
End If

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within sams_ipc_w_reg
integer x = 87
integer y = 64
integer width = 1984
integer height = 276
string dataobject = "sams_ipc_dw_req_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "b1w_hlp_customerm"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"


String ls_ref_desc
String ls_filter
INTEGER  li_exist
DataWindowChild ldwc
date	ldt_saledt


is_emp_grp		= ""
is_customerid	= ""
is_caldt 		= ""
is_userid 		= ""
is_pgm_id 		= ""


//dw_cond.reset()


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.memberid[1] 	= dw_cond.iu_cust_help.is_data[4]
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm, ls_memberid

Choose Case dwo.name
	Case "memberid"
		ls_memberid = trim(data)
		select customerid, customernm
		  INTO :ls_customerid,	:ls_customernm
		  FROM customerm
		 where memberid = :ls_memberid ;
		 
		 IF sqlca.sqlcode <> 0 OR IsNull(ls_customerid) then ls_customerid = ""
		 IF sqlca.sqlcode <> 0 OR IsNull(ls_customernm) then ls_customernm = ""
		 
		IF ls_customerid = "" THEN
			This.Object.memberid[1] =  ""
			return 0
		ELSE
			This.Object.customerid[1] =  ls_customerid
			This.Object.customernm[1] =  ls_customernm
			return 0
		end if 
	case 'customerid'
		ls_customerid 		= trim(data)
		select memberid, 			customernm
		  INTO :ls_memberid,		:ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
   	IF IsNull(ls_memberid) 		OR sqlca.sqlcode <> 0		then ls_memberid = ""
		IF IsNull(ls_customernm)  	OR sqlca.sqlcode <> 0		then ls_customernm = ""
		
//		IF sqlca.sqlcode <> 0 then 
//			This.Object.memberid[1] 	= ""
//			This.Object.customerid[1] 	= ""
//			This.Object.customernm[1] 	= ""
//			f_msg_usr_err(9000, Title, "해당 고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")

//			dw_cond.SetFocus()
//			dw_cond.SetRow(1)
//			dw_cond.SetColumn("customerid")
			
//			return 0
//		else
			This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] 	=  ls_customernm
			return 0
//		end if
End Choose
end event

type p_ok from w_a_reg_m`p_ok within sams_ipc_w_reg
integer x = 2149
end type

type p_close from w_a_reg_m`p_close within sams_ipc_w_reg
integer x = 2149
integer y = 160
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within sams_ipc_w_reg
integer x = 69
integer y = 4
integer width = 2043
integer height = 360
end type

type p_delete from w_a_reg_m`p_delete within sams_ipc_w_reg
boolean visible = false
integer x = 315
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within sams_ipc_w_reg
boolean visible = false
integer x = 23
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within sams_ipc_w_reg
integer x = 123
integer y = 1628
end type

type dw_detail from w_a_reg_m`dw_detail within sams_ipc_w_reg
integer x = 55
integer y = 412
integer width = 3118
integer height = 812
string dataobject = "sams_ipc_dw_req"
end type

event dw_detail::retrieveend;call super::retrieveend;Long ll

//처음 입력 했을시
If rowcount <> 0 Then
	FOR ll =  1 to rowcount
		this.Object.chk[ll] =  'Y'
	NEXT
End If

p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_ensable")
dw_cond.Enabled = True


end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within sams_ipc_w_reg
integer x = 448
integer y = 1628
end type

