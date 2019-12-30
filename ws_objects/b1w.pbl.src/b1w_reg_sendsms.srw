$PBExportHeader$b1w_reg_sendsms.srw
$PBExportComments$[kem] BroadCasting SMS
forward
global type b1w_reg_sendsms from w_a_reg_m_m
end type
type p_1 from u_p_fileread within b1w_reg_sendsms
end type
type gb_master from groupbox within b1w_reg_sendsms
end type
type p_saveas from u_p_saveas within b1w_reg_sendsms
end type
type dw_2 from u_d_indicator within b1w_reg_sendsms
end type
end forward

global type b1w_reg_sendsms from w_a_reg_m_m
integer width = 3218
integer height = 2168
event ue_fileread ( )
event type boolean ue_fileread_complete ( string as_path )
p_1 p_1
gb_master gb_master
p_saveas p_saveas
dw_2 dw_2
end type
global b1w_reg_sendsms b1w_reg_sendsms

type variables
String is_priceplan		//Price Plan Code
String is_actstatus
Boolean ib_save
String is_date_check  //개통일 Check 여부

end variables

forward prototypes
public subroutine of_resizepanels ()
end prototypes

event ue_fileread;//승인 요청 된 파일 불러옴
Constant Integer li_MAX_DIR = 255
String ls_filename, ls_pathname, ls_curdir, ls_path
Int li_rc, li_return
Long ll_row
Boolean	lb_return
string ls_sysdate  , ls_sysdate1
datetime ldt_sysdate

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

//파일 선택
li_rc = GetFileOpenName("Select File" , ls_pathname, ls_filename, '', &
						'Excel Files (*.xls), *.xls,' + 'Text Files (*.txt), *.txt')
//						'Text Files(*.TXT), *.TXT')
						
If li_rc <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_info(1001, Title, ls_filename)
	Return
End If

dw_detail.Reset()
ll_row= dw_detail.RowCount()
// modified by hcjung 2007-03-14
//li_rc = dw_detail.importfile(ls_pathname)

If Upper(RightA(ls_filename, 3)) = 'TXT' Then
	li_return = dw_detail.ImportFile(ls_pathname)
	
Else
//xls	
	If Trigger Event ue_fileread_complete(ls_pathname) = False Then
		f_msg_info(9000, This.Title, "File Upload Error")
		Return
	End If
	
	li_return = 1
End If



If li_rc < 0 Then
	f_msg_info(9000, Title, "적합하지 않은 파일입니다. 확인 바랍니다.")
End If

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api
ls_pathname = ""

dw_cond.Enabled = False
dw_master.InsertRow(0)

dw_master.SetFocus()

select to_char(sysdate, 'yyyymmdd'), to_char(sysdate, 'hh24miss'), sysdate
into :ls_sysdate                   , :ls_sysdate1                , :ldt_sysdate
from dual;


dw_master.object.reqdt[1] = ldt_sysdate //ldt_sysdate


p_insert.TriggerEvent('ue_enable')
p_delete.TriggerEvent('ue_enable')
p_save.TriggerEvent('ue_enable') 
p_reset.TriggerEvent('ue_enable') 
end event

event ue_fileread_complete;Integer li_rtn
Long	  ll_xls, ll_import
String  ls_save_file

//--------------------------------------------------------------------- 
OleObject oleExcel 

oleExcel = Create OleObject 
li_rtn = oleExcel.connecttonewobject("excel.application") 

//Excel Open
If li_rtn = 0 Then
	oleExcel.WorkBooks.Open(as_path) 
Else
//Excel Destroy	
	Destroy oleExcel 
	Return False
End If

//Visible False
oleExcel.Application.Visible = False 

//txt파일로 save
ll_xls = PosA(as_path, 'xls')
ls_save_file = MidA(as_path, 1, ll_xls -2) + string(now(),'hhmmss') + '.txt'
oleExcel.application.workbooks(1).SaveAs(ls_save_file, -4158) 

//save후 Destroy
oleExcel.application.workbooks(1).Saved = True 
oleExcel.Application.Quit 
oleExcel.DisConnectObject() 
Destroy oleExcel

//txt파일 imoport
ll_import = dw_detail.ImportFile(ls_save_file)

SetPointer(Arrow!)

if ll_import < 1 Then
	
end if

//txt파일 delete
FileDelete(ls_save_file)

return True
end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(dw_cond.x, ii_WindowTop)
idrg_Top.Resize(dw_cond.Width + 400, st_horizontal.Y - idrg_Top.Y - 20)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width + 500, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)
end subroutine

on b1w_reg_sendsms.create
int iCurrent
call super::create
this.p_1=create p_1
this.gb_master=create gb_master
this.p_saveas=create p_saveas
this.dw_2=create dw_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.gb_master
this.Control[iCurrent+3]=this.p_saveas
this.Control[iCurrent+4]=this.dw_2
end on

on b1w_reg_sendsms.destroy
call super::destroy
destroy(this.p_1)
destroy(this.gb_master)
destroy(this.p_saveas)
destroy(this.dw_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_sendsms
	Desc.	: 	BroadCasting SMS
	Ver.	:	1.0
	Date	: 	2003.12.11
	Programer : kem
--------------------------------------------------------------------------*/

end event

event ue_ok;call super::ue_ok;String ls_value, ls_name, ls_stitle, ls_birthfr, ls_birthto, ls_method, ls_bilcycle
String ls_where, ls_ctype1, ls_ctype2, ls_location, ls_clevel, ls_svccod, ls_priceplan, ls_status
String ls_activefr, ls_activeto, ls_termfr, ls_termto, ls_prefixno, ls_buildingno, ls_roomno, ls_suspendfr, ls_suspendto
string ls_termtype, ls_suspend_type
Date ld_birthfr, ld_birthto
Long ll_row
string ls_sysdate,ls_sysdate1
datetime ldt_sysdate


// add by hcjung 2007-03-13
String ls_base, ls_over_status, ls_modify_date
ls_over_status = Trim(dw_cond.object.over_status[1])
ls_modify_date = String(dw_cond.object.modify_date[1],'yyyymmdd')
If IsNull(ls_base) 			Then ls_base 			= ""
If IsNull(ls_over_status) 	Then ls_over_status 	= ""
If IsNull(ls_modify_date)	Then ls_modify_date	= ""

ls_value    = Trim(dw_cond.object.value[1])
ls_name     = Trim(dw_cond.object.name[1])
ls_stitle   = Trim(dw_cond.object.stitle[1])
ls_birthfr  = "" //Trim(dw_cond.object.birthfr[1])
ls_birthto  = "" //Trim(dw_cond.object.birthto[1])
ls_method   = Trim(dw_cond.object.method[1])
ls_bilcycle = "" //Trim(dw_cond.object.bilcycle[1])
ls_ctype1    = Trim(dw_cond.object.ctype1[1])
ls_ctype2    = Trim(dw_cond.object.ctype2[1])
ls_location  = "" //Trim(dw_cond.object.location[1])
ls_clevel    = Trim(dw_cond.object.clevel[1])
ls_activefr  = String(dw_cond.object.activefr[1], 'yyyymmdd')
ls_activeto  = String(dw_cond.object.activeto[1], 'yyyymmdd')
ls_termfr    = String(dw_cond.object.termfr[1], 'yyyymmdd')
ls_termto    = String(dw_cond.object.termto[1], 'yyyymmdd')
ls_svccod    = Trim(dw_cond.object.svccod[1])
ls_base      = Trim(dw_cond.object.base[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_status    = Trim(dw_cond.object.status[1])
ls_prefixno  = "" //Trim(dw_cond.object.reg_partner[1])
ls_buildingno= Trim(dw_cond.object.buildingno[1])
ls_roomno    = Trim(dw_cond.object.roomno[1])
ls_suspendfr  = String(dw_cond.object.suspendfr[1], 'yyyymmdd')
ls_suspendto  = String(dw_cond.object.suspendto[1], 'yyyymmdd')
ls_termtype   = Trim(dw_cond.object.termtype[1])
ls_suspend_type = Trim(dw_cond.object.suspend_type[1])

//Null Check
If IsNull(ls_value)     Then ls_value = ""
If IsNull(ls_name)      Then ls_name = ""
If IsNull(ls_stitle)    Then ls_stitle = ""
If IsNull(ls_birthfr)   Then ls_birthfr = ""
If IsNull(ls_birthto)   Then ls_birthto = ""
If IsNull(ls_method)    Then ls_method = ""
If IsNull(ls_bilcycle)  Then ls_bilcycle = ""
If IsNull(ls_ctype1)    Then ls_ctype1 = ""
If IsNull(ls_ctype2)    Then ls_ctype2 = ""
If IsNull(ls_location)  Then ls_location = ""
If IsNull(ls_clevel)    Then ls_clevel = ""
If IsNull(ls_activefr)  Then ls_activefr = ""
If IsNull(ls_activeto)  Then ls_activeto = ""
If IsNull(ls_termfr)    Then ls_termfr = ""
If IsNull(ls_termto)    Then ls_termto = ""
If IsNull(ls_svccod)    Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_status)    Then ls_status = ""
If IsNull(ls_prefixno)  Then ls_prefixno = ""

//날짜 체크
If ls_birthfr <> "" Then
	If IsDate('2003/' + LeftA(ls_birthfr,2) + '/' + RightA(ls_birthfr,2)) = False Then
		f_msg_usr_err(210, Title, "생일")
		dw_cond.SetFocus()
		dw_cond.setColumn("birthfr")
		Return
	End If
	ld_birthfr = Date("2003-" + LeftA(ls_birthfr,2) + "-" + RightA(ls_birthfr,2))
End If

If ls_birthto <> "" Then
	If IsDate('2003/' + LeftA(ls_birthto,2) + '/' + RightA(ls_birthto,2)) = False Then
		f_msg_usr_err(210, Title, "생일")
		dw_cond.SetFocus()
		dw_cond.setColumn("birthto")
		Return
	End If
	ld_birthto = Date("2003-" + LeftA(ls_birthto,2) + "-" + RightA(ls_birthto,2))
End If

If ls_birthfr <> "" And ls_birthto <> "" Then
	If fi_chk_frto_day(ld_birthfr, ld_birthto) < 0 Then
		f_msg_usr_err(211, Title, "생일")
		dw_cond.SetFocus()
		dw_cond.setColumn("birthfr")
		Return
	End If
ElseIf ls_birthfr <> "" And ls_birthto = "" Then
	ls_birthto = "1231"
ElseIf ls_birthfr = "" And ls_birthto <> "" Then
	ls_birthfr = "0101"
End If


ls_where = ""

If ls_value <> "" Then
	If ls_where <> "" Then ls_where += " And "
	Choose Case ls_value
		Case "customerid"
			ls_where += " a.customerid like '" + ls_name + "%' "
		Case "customernm"
			ls_where += "Upper(a.customernm) like '%" + Upper(ls_name) + "%' "
		Case "email"
			ls_where += "Upper(a.EMAIL1)     like '%" + Upper(ls_name) + "%' "
		Case "logid"
			ls_where += "Upper(a.logid)      like '%" + Upper(ls_name) + "%' "
		Case "bil_mail"
			ls_where += "Upper(b.bil_email)  like '%" + Upper(ls_name) + "%' "
		Case "cellphone"
			ls_where += "Upper(a.cellphone)  like '%" + Upper(ls_name) + "%' "
		Case "buildingno"
			ls_where += "Upper(a.buildingno) like '%" + Upper(ls_name) + "%' "
		Case "roomno"
			ls_where += "Upper(a.roomno)     like '%" + Upper(ls_name) + "%' "
	End Choose		
End If

If ls_stitle <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stitle = '" + ls_stitle + "' "
End If

If ls_birthfr <> "" And ls_birthto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(a.birthdt, 'mmdd') >= '" + ls_birthfr + "' "
	ls_where += " And to_char(a.birthdt, 'mmdd') <= '" + ls_birthto + "' "
End If

If ls_ctype1 <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.ctype1 = '" + ls_ctype1 + "' "
End if

If ls_ctype2 <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.ctype2 = '" + ls_ctype2 + "' "
End if

If ls_location <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.location = '" + ls_location + "' "
End if

If ls_clevel <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.clevel = '" + ls_clevel + "' "
End if

If ls_method <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += " b.pay_method = '" + ls_method + "' "
End If

If ls_bilcycle <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " b.bilcycle = '" + ls_bilcycle + "' " 
End if

If ls_method <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += " b.pay_method = '" + ls_method + "' "
End If

If ls_bilcycle <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " b.bilcycle = '" + ls_bilcycle + "' "
End if

If ls_prefixno <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.reg_prefixno Like '" + ls_prefixno + "%' "
End if

If ls_activefr <> "" And ls_activeto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.activedt, 'yyyymmdd') >= '" + ls_activefr + "' "
	ls_where += " And to_char(c.activedt, 'yyyymmdd') <= '" + ls_activeto + "' "
	
ElseIf ls_activefr <> "" And ls_activeto = "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.activedt, 'yyyymmdd') >= '" + ls_activefr + "' "
	
ElseIf ls_activefr = "" And ls_activeto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.activedt, 'yyyymmdd') <= '" + ls_activeto + "' "
End If

If ls_termfr <> "" And ls_termto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.termdt, 'yyyymmdd') >= '" + ls_termfr + "' "
	ls_where += " And to_char(c.termdt, 'yyyymmdd') <= '" + ls_termto + "' "
	
ElseIf ls_termfr <> "" And ls_termto = "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.termdt, 'yyyymmdd') >= '" + ls_termfr + "' "
	
ElseIf ls_termfr = "" And ls_termto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.termdt, 'yyyymmdd') <= '" + ls_termto + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.svccod = '" + ls_svccod + "' "
End if

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.priceplan = '" + ls_priceplan + "' "
End if

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.status = '" + ls_status + "' "
End if

// Add by hcjung 2007-03-13
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.basecod = '" + ls_base + "' "
End If
If ls_over_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " d.status = '" + ls_over_status + "' "
End If

If ls_modify_date <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(d.modify_date,'yyyymmdd') = '" + ls_modify_date + "' "
End If

If ls_buildingno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	//ls_where += " a.buildingno = '" + ls_buildingno + "' "
	ls_where += " a.buildingno Like '" + ls_buildingno + "%' "
End If

If ls_roomno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	//ls_where += " a.roomno = '" + ls_roomno + "' "
	ls_where += " a.roomno Like '" + ls_roomno + "%' "
End If

// 정지일
If ls_suspendfr <> "" And ls_suspendto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(d.suspend_date, 'yyyymmdd') >= '" + ls_suspendfr + "' "
	ls_where += " And to_char(d.suspend_date, 'yyyymmdd') <= '" + ls_suspendto + "' "
	
ElseIf ls_suspendfr <> "" And ls_suspendto = "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(d.suspend_date, 'yyyymmdd') >= '" + ls_suspendfr + "' "
	
ElseIf ls_suspendfr = "" And ls_suspendto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(d.suspend_date, 'yyyymmdd') <= '" + ls_suspendto + "' "
End If

if ls_status = '20' then // Activation

elseif ls_status = '99' then // Termination
	If ls_termtype <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " c.termtype = '" + ls_termtype + "' "
	End If
elseif ls_status = '40' then // Suspend
	If ls_suspend_type <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " c.suspend_type = '" + ls_suspend_type + "' "
	End If
end if
	
	

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If
//

//dw_2.SettransObject(sqlca)
//dw_2.is_where = ls_where
//ll_row = dw_2.Retrieve()
//

dw_cond.Enabled = False
dw_master.InsertRow(0)
dw_master.SetFocus()

select to_char(sysdate, 'yyyymmdd'), to_char(sysdate, 'hh24miss'), sysdate+(1/24/60)
into :ls_sysdate                   , :ls_sysdate1                , :ldt_sysdate
from dual;


dw_master.object.reqdt[1] = ldt_sysdate //ldt_sysdate


p_insert.TriggerEvent('ue_enable')
p_delete.TriggerEvent('ue_enable')
p_save.TriggerEvent('ue_enable') 
p_reset.TriggerEvent('ue_enable') 

end event

event ue_extra_save;//Save Check
String ls_activedt, ls_bil_fromdt, ls_sysdt, ls_customerid, ls_chk
Long ll_rows , ll_rc, ll_row, ll_cnt, i
b1u_dbmgr6 lu_dbmgr6

dw_master.AcceptText()
dw_detail.AcceptText()


ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

For ll_row = 1 To dw_detail.RowCount()
	ls_chk = dw_detail.object.chk[ll_row]
	
	If ls_chk = 'Y' Then
		ll_cnt ++
	End If
Next

If ll_cnt = 0 Then
	f_msg_info(9000, Title, "SMS 전송을 위한 고객을 선택하지 않았습니다.")
	Return -1
End If


lu_dbmgr6 = CREATE b1u_dbmgr6

//2011.07.15 이윤주 대리 요청사항으로 수정함.
//lu_dbmgr6.is_caller = "b1w_reg_sendsms%save"
lu_dbmgr6.is_caller = "b1w_reg_sendsms_new%save"
lu_dbmgr6.is_title  = Title
lu_dbmgr6.idw_data[1] = dw_master
lu_dbmgr6.idw_data[2] = dw_detail

lu_dbmgr6.uf_prc_db()
ll_rc = lu_dbmgr6.ii_rc

If ll_rc < 0 Then
	dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
	For i = 1 To dw_detail.RowCount()
		dw_detail.SetItemStatus(i, 0, Primary!, NotModified!)
	Next
	Destroy lu_dbmgr6
	Return ll_rc
End If

dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
For i = 1 To dw_detail.RowCount()
	dw_detail.SetItemStatus(i, 0, Primary!, NotModified!)
Next

Destroy lu_dbmgr6

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
Long ll_row
Int li_rc

Constant Int LI_ERROR = -1

If dw_master.AcceptText() < 0 And dw_detail.AcceptText() < 0 Then
	dw_master.SetFocus()
	Return LI_ERROR
End if

li_rc = This.Trigger Event ue_extra_save()

If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"SendSMS")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"SendSMS")
ElseIF li_rc = -2 Then
	Return LI_ERROR
ElseIf li_rc = -3 Then
	Return LI_ERROR
End if

//Reset
Trigger Event ue_reset()

Return 0
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

event type integer ue_reset();call super::ue_reset;
dw_master.InsertRow(0)

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
dw_detail.object.chk[al_insert_row] = 'Y'

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_sendsms
integer x = 46
integer y = 56
integer width = 2222
integer height = 716
string dataobject = "b1dw_cnd_sendsms"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan
Integer li_exist
String  ls_filter, ls_status


Choose Case dwo.name
	Case "svccod"
		
		If IsNull(data) Or data = "" Then
			
		Else
			li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			ls_filter = "svccod = '" + data + "' " 
			ldc_priceplan.SetTransObject(SQLCA)
			li_exist =ldc_priceplan.Retrieve()
			ldc_priceplan.SetFilter(ls_filter)			//Filter정함
			ldc_priceplan.Filter()
			
			If li_exist < 0 Then 				
			  f_msg_usr_err(2100, Title, "Retrieve()")
			  Return 1  		//선택 취소 focus는 그곳에
			End If
			
		End If
	Case "status"		
         ls_status 		= data

			if ls_status = '40' then // suspension
				This.object.termtype.visible     = false;
				This.object.suspend_type.visible = true;	
				This.object.suspend_type.Protect = 0		
			elseif ls_status = '99' then // termination
				This.object.termtype.visible     = true;
				This.object.termtype.Protect     = 0
				This.object.suspend_type.visible = false;			
				
			else // Activation
				This.object.termtype[1]          = ""
				This.object.suspend_type[1]      = ""				
				This.object.termtype.visible     = true;
				This.object.termtype.Protect     = 1  // protect
				This.object.suspend_type.visible = false;			
			end if
End Choose
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_sendsms
integer x = 2377
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_sendsms
integer x = 2377
integer y = 164
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_sendsms
integer x = 27
integer width = 2304
integer height = 812
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_sendsms
integer x = 50
integer y = 868
integer width = 2871
integer height = 384
string dataobject = "b1dw_reg_sendsms_master"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
end type

event dw_master::clicked;//
end event

event dw_master::constructor;SetTransObject(SQLCA)

Trigger Event ue_init()

This.SetRowFocusIndicator(Off!)
end event

event dw_master::editchanged;call super::editchanged;string ls_msg
long ll_length

choose  case dwo.name
	case 'msg'
		//ls_msg = this.GetItemString(1, "msg")
		
		ll_length = LenA(data)
		
		this.Setitem(1, "countnum", ll_length)

	
end choose

end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_sendsms
integer y = 1320
integer width = 3113
integer height = 592
string dataobject = "b1dw_reg_sendsms_detail"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_detail::buttonclicked;call super::buttonclicked;String ls_chk
Long   ll_row

//FILE READ 후 선택버튼 전체선택이 가능토록 요청.(2011.11.09 박지영팀장)
// kem modify 2011.11.28
If dwo.name = 'b_allchk' Then
	
	ls_chk = Trim(dw_detail.Object.chk[1])
	
	For ll_row = 1 To dw_detail.Rowcount()
		//messagebox('ll_row',ll_row)
		If ls_chk = 'N' Then
			dw_detail.Object.chk[ll_row] = 'Y'
		Else
			dw_detail.Object.chk[ll_row] = 'N'
		End If
	Next
	
End If 
//////////////////////////////////////////////////////
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_sendsms
integer y = 1936
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_sendsms
integer y = 1936
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_sendsms
integer x = 617
integer y = 1936
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_sendsms
integer x = 910
integer y = 1936
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_sendsms
integer x = 32
integer y = 1272
end type

type p_1 from u_p_fileread within b1w_reg_sendsms
integer x = 2377
integer y = 280
boolean bringtotop = true
boolean originalsize = false
end type

type gb_master from groupbox within b1w_reg_sendsms
integer x = 23
integer y = 816
integer width = 3127
integer height = 452
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

type p_saveas from u_p_saveas within b1w_reg_sendsms
integer x = 2382
integer y = 396
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;call super::clicked;f_excel_ascii1(dw_detail,'b1dw_reg_sendsms_detail_saveas')

//datawindow	ldw
//
//ldw = dw_2
//
//f_excel(ldw)


//
////datawindow(dw_master)
////string(as_filenm)
////
//
//OLEObject lo_excel
//String    ls_RegistryPath , ls_Excelpath
//String    ls_xlsname      , ls_FileName
//Integer   li_Re, li_fp
//
////ls_xlsname = as_filenm
//
////dw_2.SetTransObject(sqlca)
////dw_master.RowsCopy(dw_master.GetRow(), dw_master.RowCount(), Primary!, dw_2, 1, Primary!)
//
//
//IF dw_2.Rowcount() < 1 THEN
//	MessageBox("작업오류", '엑셀파일로 전환할 내용이 없습니다.', Information!)
//	RETURN -1
//END IF
//
//IF GetFileSaveName("Select File", ls_xlsname, ls_FileName, "xls", "Excel Files (*.xls),*.xls") <> 1 THEN
//	Messagebox("작업취소", "작업을 취소했습니다!", Exclamation!)
//	RETURN -1
//END IF
//
//IF FileExists(ls_xlsname) THEN
//	IF MessageBox("Select File", ls_xlsname + " File이 존재합니다.~n" + &
//									"덮어 쓰시겠습니까?", Question!, yesno!, 2) = 2 THEN		RETURN -1
//END IF
//
//IF dw_2.SaveAsAscii(ls_xlsname) <> 1 THEN
//	li_fp = Fileopen(ls_xlsname,StreamMode!, Write!, LockWrite!, Replace!)
//	IF li_fp < 1 THEN
//		Messagebox('파일로 저장','오류 : File 지정이 잘못되었습니다.')
//		RETURN -1
//	END IF
//END IF
//
////lo_excel = CREATE OLEobject
////
////IF lo_excel.ConnectToNewObject("excel.application") <> 0 THEN
////	MessageBox('확인' , '엑셀 실행화일을 찾을 수 없습니다.')
////	DESTROY lo_excel
////	Return -1
////ELSE
////	lo_excel.windowstate = 1
////	lo_excel.application.Visible = True
////	lo_excel.windowstate = 3
////	
////	lo_excel.application.workbooks.opentext(ls_xlsname)
////	lo_excel.DisConnectObject()
////	DESTROY lo_excel
////END IF
////
////RETURN 0
end event

type dw_2 from u_d_indicator within b1w_reg_sendsms
boolean visible = false
integer x = 1394
integer y = 1288
integer width = 1595
integer height = 592
integer taborder = 40
boolean bringtotop = true
boolean enabled = false
string dataobject = "b1dw_reg_sendsms_detail_saveas"
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

