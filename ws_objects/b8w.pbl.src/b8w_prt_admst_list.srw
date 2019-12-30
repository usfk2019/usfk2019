$PBExportHeader$b8w_prt_admst_list.srw
$PBExportComments$[juede] 장비리스트
forward
global type b8w_prt_admst_list from w_a_print
end type
end forward

global type b8w_prt_admst_list from w_a_print
integer width = 3982
end type
global b8w_prt_admst_list b8w_prt_admst_list

on b8w_prt_admst_list.create
call super::create
end on

on b8w_prt_admst_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False

end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_todt, ls_fromdt
String ls_idatefrom, ls_idateto, ls_movedtfrom, ls_movedtto
String ls_modelno, ls_status, ls_adstat, ls_mvpartner, ls_snpartner
date ld_idateto, ld_idatefrom, ld_movedtfrom, ld_movedtto
Long ll_row



ld_idateto 		= dw_cond.object.idateto[1]
ld_idatefrom 	= dw_cond.object.idatefrom[1]
ld_movedtto 	= dw_cond.object.movedtto[1]
ld_movedtfrom 	= dw_cond.object.movedtfrom[1]
ls_idateto 		= String(ld_idateto, 'yyyymmdd')
ls_idatefrom 	= String(ld_idatefrom, 'yyyymmdd')
ls_movedtfrom 	= String(ld_movedtfrom, 'yyyymmdd')
ls_movedtto 	= String(ld_movedtto, 'yyyymmdd')
ls_modelno	 	= Trim(dw_cond.Object.modelno[1])
ls_status 		= Trim(dw_cond.Object.status[1])
ls_adstat 		= Trim(dw_cond.Object.adstat[1])
ls_snpartner 	= Trim(dw_cond.object.sn_partner[1])
ls_mvpartner 	= Trim(dw_cond.Object.mv_partner[1])

If IsNull(ls_idateto) 		Then ls_idateto = ""
If IsNull(ls_idatefrom) 	Then ls_idatefrom = ""
If IsNull(ls_movedtto) 		Then ls_movedtto = ""
If IsNull(ls_movedtfrom) 	Then ls_movedtfrom = ""
If IsNull(ls_modelno)		Then ls_modelno = ""
If IsNull(ls_status)			Then ls_status = ""
If IsNull(ls_adstat)			Then ls_adstat = ""
If IsNull(ls_snpartner)		Then ls_snpartner = ""
If IsNull(ls_mvpartner)		Then ls_mvpartner = ""


ls_where =" A.Modelno  = M.MODELNO(+) AND  A.CUSTOMERID = C.CUSTOMERID(+) "

If ls_modelno <> "" Then
	ls_where += " And  A.modelno = '" + ls_modelno +"'  "
End If

If ls_status <> "" Then
	ls_where += " And A.status = '" + ls_status +"' "
End If

If ls_adstat <> "" Then
	//If ls_where <> "" Then
		ls_where +=" And A.adstat = '" +ls_adstat +"'  "
	//End If
End If

If ls_mvpartner <> "" Then
	//If ls_where <> "" Then
		ls_where +=" And A.mv_partner = '" +ls_mvpartner+ "'  "
	//End If
End If

If ls_snpartner <> "" Then
	//If ls_where <> "" Then
		ls_where +=" And A.sn_partner ='" +ls_snpartner+ "'  "
	//End If
End If



//ranger가 확정이 되면
If ls_idatefrom <> ""  and ls_idateto <> "" Then
	ll_row = fi_chk_frto_day(ld_idatefrom, ld_idateto)
	If ll_row < 0 Then
	 f_msg_usr_err(211, Title, "입고일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("idatefrom")
	 Return 
	End If 	
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(idate, 'YYYYMMDD') >='" + ls_idatefrom + "' " + &
				"and to_char(idate, 'YYYYMMDD') < = '" + ls_idateto + "' "
			  
ElseIf ls_idatefrom <> "" and ls_idateto = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(idate,'YYYYMMDD') > = '" + ls_idatefrom + "' "
ElseIf ls_idatefrom = "" and ls_idateto <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(idate, 'YYYYMMDD') < = '" + ls_idateto + "' " 
End If

//ranger가 확정이 되면
If ls_movedtfrom <> ""  and ls_movedtto <> "" Then
	ll_row = fi_chk_frto_day(ld_movedtfrom, ld_movedtto)
	If ll_row < 0 Then
	 f_msg_usr_err(211, Title, "입고일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("movedtfrom")
	 Return 
	End If 	
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(movedt, 'YYYYMMDD') >='" + ls_movedtfrom + "' " + &
				"and to_char(movedt, 'YYYYMMDD') < = '" + ls_movedtto + "' "
			  
ElseIf ls_movedtfrom <> "" and ls_movedtto = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(movedt,'YYYYMMDD') > = '" + ls_movedtfrom + "' "
ElseIf ls_movedtfrom = "" and ls_movedtto <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(movedt, 'YYYYMMDD') < = '" + ls_movedtto + "' " 
End If



If ls_idatefrom <> ""  Then
	dw_list.object.fromdt_t.Text = String(ld_idatefrom,'yyyy-mm-dd') 
End If

If ls_idateto <> "" Then
	dw_list.object.todt_t.Text = String(ld_idateto,'yyyy-mm-dd') 
End If

If ls_movedtfrom <> ""  Then
	dw_list.object.mv_fromdt_t.Text = String(ld_movedtfrom,'yyyy-mm-dd') 
End If

If ls_movedtto <> "" Then
	dw_list.object.mv_todt_t.Text = String(ld_movedtto,'yyyy-mm-dd') 
End If


dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b8w_prt_admst_list
	Desc.	: 장비리스트
	Date	: 2005.12.29
	Ver.	: 1.0
	Programer : juede
-------------------------------------------------------------------------*/

end event

event ue_reset();call super::ue_reset;dw_list.object.fromdt_t.Text = ""
dw_list.object.todt_t.Text = ""
dw_list.object.mv_fromdt_t.Text = ""
dw_list.object.mv_todt_t.Text = ""


end event

type dw_cond from w_a_print`dw_cond within b8w_prt_admst_list
integer x = 87
integer y = 88
integer width = 2537
integer height = 376
string dataobject = "b8dw_cnd_inq_admst_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;//DataWindowChild ldc_partner
//Long li_exist
//String ls_filter
//
//Choose Case dwo.name
//	Case "levelcod"
//		//LEVELCOD가 바뀜에 따라서 대리점 바뀐다...
//		This.object.partner[row] = ''		//DDDW 구함				
//		li_exist = this.GetChild("partner", ldc_partner)		//DDDW 구함
//		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 대리점")
//	
//		ls_filter = "levelcod = '" + data  + "'" 				
//		ldc_partner.SetTransObject(SQLCA)
//		li_exist =ldc_partner.Retrieve()
//		ldc_partner.SetFilter(ls_filter)			//Filter정함
//		ldc_partner.Filter()
//		
//		If li_exist < 0 Then 				
//			f_msg_usr_err(2100, Title, "Retrieve()")
//			Return 1  		//선택 취소 focus는 그곳에
//		End If  
//
//End Choose	
end event

type p_ok from w_a_print`p_ok within b8w_prt_admst_list
integer x = 2779
integer y = 48
end type

type p_close from w_a_print`p_close within b8w_prt_admst_list
integer x = 3095
integer y = 48
end type

type dw_list from w_a_print`dw_list within b8w_prt_admst_list
integer x = 23
integer y = 512
integer width = 3890
integer height = 1092
string dataobject = "b8dw_prt_admst_list"
end type

type p_1 from w_a_print`p_1 within b8w_prt_admst_list
end type

type p_2 from w_a_print`p_2 within b8w_prt_admst_list
end type

type p_3 from w_a_print`p_3 within b8w_prt_admst_list
end type

type p_5 from w_a_print`p_5 within b8w_prt_admst_list
end type

type p_6 from w_a_print`p_6 within b8w_prt_admst_list
end type

type p_7 from w_a_print`p_7 within b8w_prt_admst_list
end type

type p_8 from w_a_print`p_8 within b8w_prt_admst_list
end type

type p_9 from w_a_print`p_9 within b8w_prt_admst_list
end type

type p_4 from w_a_print`p_4 within b8w_prt_admst_list
end type

type gb_1 from w_a_print`gb_1 within b8w_prt_admst_list
end type

type p_port from w_a_print`p_port within b8w_prt_admst_list
end type

type p_land from w_a_print`p_land within b8w_prt_admst_list
end type

type gb_cond from w_a_print`gb_cond within b8w_prt_admst_list
integer x = 27
integer y = 8
integer width = 2651
integer height = 476
end type

type p_saveas from w_a_print`p_saveas within b8w_prt_admst_list
end type

