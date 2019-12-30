$PBExportHeader$b5w_1_reg_billing_receipt_ae.srw
$PBExportComments$[juede] 빌링자료 파일 처리
forward
global type b5w_1_reg_billing_receipt_ae from w_a_prc
end type
end forward

global type b5w_1_reg_billing_receipt_ae from w_a_prc
integer width = 2066
integer height = 1288
end type
global b5w_1_reg_billing_receipt_ae b5w_1_reg_billing_receipt_ae

type variables
Integer ii_rowcount
end variables

on b5w_1_reg_billing_receipt_ae.create
call super::create
end on

on b5w_1_reg_billing_receipt_ae.destroy
call super::destroy
end on

event type integer ue_process();String 	ls_fileName
Int		li_fileId

ls_fileName = Trim(dw_input.Object.filename[1])
IF isNull(ls_fileName) THEN ls_fileName = ""

IF ls_fileName = "" THEN
	f_msg_info(200, This.Title, "파일명")
	This.SetFocus()
	RETURN -1
END IF

b5u_1_dbmgr lu_dbmgr
lu_dbmgr = Create b5u_1_dbmgr

lu_dbmgr.is_caller = "b5w_1_reg_billing_receipt"
lu_dbmgr.is_Title = This.Title
lu_dbmgr.is_data[1] = ls_fileName

lu_dbmgr.uf_prc_db()

If lu_dbmgr.ii_rc = -1 THen
	Destroy lu_dbmgr
	return -1
Elseif lu_dbmgr.ii_rc > 0 then
	MessageBox("파일 처리 완료!! ","파일이름 ["+ ls_fileName + " ]의 처리가 완료되었습니다.")			

End IF
		

is_msg_process = '처리건수:' + string(lu_dbmgr.ii_rc) 

return 0

end event

event type integer ue_input();
Return 0

end event

type p_ok from w_a_prc`p_ok within b5w_1_reg_billing_receipt_ae
integer x = 1673
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b5w_1_reg_billing_receipt_ae
integer y = 84
integer width = 1522
integer height = 144
string dataobject = "b5dw_1_file_reg_receipt"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::buttonclicked;CHOOSE CASE	dwo.Name
	CASE "search"	//파일찾기
		string pathName, fileName

		Int value

		value = GetFileOpenName("Select File", &
				+ pathName, fileName, "TXT", &
				+ "Text Files (*.TXT),*.TXT")

		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
				
END CHOOSE
end event

type dw_msg_time from w_a_prc`dw_msg_time within b5w_1_reg_billing_receipt_ae
integer y = 860
integer width = 1975
integer height = 300
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_1_reg_billing_receipt_ae
integer y = 296
integer width = 1970
integer height = 548
end type

type ln_up from w_a_prc`ln_up within b5w_1_reg_billing_receipt_ae
integer beginy = 276
integer endy = 276
end type

type ln_down from w_a_prc`ln_down within b5w_1_reg_billing_receipt_ae
integer beginy = 1172
integer endx = 1902
integer endy = 1172
end type

type p_close from w_a_prc`p_close within b5w_1_reg_billing_receipt_ae
integer x = 1673
integer y = 156
end type

type gb_cond from w_a_prc`gb_cond within b5w_1_reg_billing_receipt_ae
integer width = 1582
integer height = 256
end type

