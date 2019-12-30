$PBExportHeader$sams_ipc_w_prt.srw
$PBExportComments$[hcjung] IPC 카드 충전 조회
forward
global type sams_ipc_w_prt from w_a_print
end type
end forward

global type sams_ipc_w_prt from w_a_print
end type
global sams_ipc_w_prt sams_ipc_w_prt

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where,ls_bil_fromdt,ls_customerid,ls_recharge_type,ls_result

ls_customerid 		= Trim(dw_cond.Object.customerid[1])
ls_result         = Trim(dw_cond.Object.result[1])
ls_bil_fromdt 		= String(dw_cond.Object.rechargedt[1],'yyyymmdd')


IF IsNull(ls_customerid) 		THEN ls_customerid   = ""
IF IsNull(ls_result)	         THEN ls_result       = ""
IF IsNull(ls_bil_fromdt)      THEN ls_bil_fromdt   = ""

ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " customerid = '" + ls_customerid + "' "
END IF

IF ls_bil_fromdt <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " to_char(updtdt,'yyyymmdd') = '" + ls_bil_fromdt + "' "
END IF

// S or F 가 아니면 무조건 All 로 검색 
IF ls_result = "S" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " result = '0000' "
ELSEIF ls_result = "F" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " result != '0000' "
END IF

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

IF ll_row < 0 THEN 
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN
ELSEIF ll_row = 0 THEN
	f_msg_usr_err(1100, Title, "")
	RETURN
END IF


end event

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_list
end event

on sams_ipc_w_prt.create
call super::create
end on

on sams_ipc_w_prt.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False
end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list,'ssrt_prt_prepay_list')

end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	sams_ipc_w_prt
	Desc.	: 	IPC 카드 일괄 충전 조회 List
	Ver.	:	1.0
	Date	: 	2008.02.13
	Programer : Jung Hee Chan [ hcjung ]
--------------------------------------------------------------------------*/

// 오늘 날짜로 검색 일자 세팅 

This.Trigger Event ue_reset() 









end event

event ue_reset();call super::ue_reset;//dw_cond.Object.rechargedt[1]				= fd_date_next(Date(fdt_get_dbserver_now()),1)
dw_cond.Object.rechargedt[1]				= fdt_get_dbserver_now()
end event

type dw_cond from w_a_print`dw_cond within sams_ipc_w_prt
integer x = 50
integer y = 72
integer width = 1920
string dataobject = "sams_ipc_dw_prt_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select customernm		  INTO :ls_customernm		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		 IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			return 1
		ELSE
			This.Object.customernm[1] 	=  ls_customernm
		END IF
End Choose

end event

type p_ok from w_a_print`p_ok within sams_ipc_w_prt
integer x = 2002
integer y = 60
end type

type p_close from w_a_print`p_close within sams_ipc_w_prt
integer x = 2313
integer y = 60
end type

type dw_list from w_a_print`dw_list within sams_ipc_w_prt
integer x = 23
integer y = 384
integer height = 1284
string dataobject = "sams_ipc_dw_prt"
end type

event dw_list::doubleclicked;call super::doubleclicked;	String ls_cid, ls_payer
	
	ls_cid 	= Trim(This.object.payid[row])
	ls_payer = Trim(This.object.customernm[row])

	iu_cust_msg = Create u_cust_a_msg

	
	iu_cust_msg.is_pgm_name = "선수금현황"
	iu_cust_msg.is_grp_name = "선수금리스트"
	iu_cust_msg.is_pgm_id 	= gs_pgm_id[gi_open_win_no]
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.is_data[1] = ls_cid					//customer ID
	iu_cust_msg.is_data[2] = ls_payer				//customer NM
   OpenWithParm(ssrt_prt_prepay_popup, iu_cust_msg)
	
DESTROY iu_cust_msg	
	 


end event

event dw_list::retrieveend;Parent.Triggerevent('ue_preview_set')
//Post Event ue_set_header()
end event

type p_1 from w_a_print`p_1 within sams_ipc_w_prt
end type

type p_2 from w_a_print`p_2 within sams_ipc_w_prt
end type

type p_3 from w_a_print`p_3 within sams_ipc_w_prt
end type

type p_5 from w_a_print`p_5 within sams_ipc_w_prt
end type

type p_6 from w_a_print`p_6 within sams_ipc_w_prt
end type

type p_7 from w_a_print`p_7 within sams_ipc_w_prt
end type

type p_8 from w_a_print`p_8 within sams_ipc_w_prt
end type

type p_9 from w_a_print`p_9 within sams_ipc_w_prt
end type

type p_4 from w_a_print`p_4 within sams_ipc_w_prt
end type

type gb_1 from w_a_print`gb_1 within sams_ipc_w_prt
end type

type p_port from w_a_print`p_port within sams_ipc_w_prt
end type

type p_land from w_a_print`p_land within sams_ipc_w_prt
end type

type gb_cond from w_a_print`gb_cond within sams_ipc_w_prt
integer y = 20
integer width = 1947
end type

type p_saveas from w_a_print`p_saveas within sams_ipc_w_prt
end type

