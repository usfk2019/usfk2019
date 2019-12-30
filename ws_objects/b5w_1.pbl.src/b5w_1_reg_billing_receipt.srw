$PBExportHeader$b5w_1_reg_billing_receipt.srw
forward
global type b5w_1_reg_billing_receipt from w_a_condition
end type
end forward

global type b5w_1_reg_billing_receipt from w_a_condition
integer width = 2336
integer height = 476
end type
global b5w_1_reg_billing_receipt b5w_1_reg_billing_receipt

on b5w_1_reg_billing_receipt.create
call super::create
end on

on b5w_1_reg_billing_receipt.destroy
call super::destroy
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_cond.Y ) Then
//	dw_cond.Height =48
//	
//Else
//	dw_cond.Height = 228
//End If
//
//If newwidth < dw_cond.X  Then
//	dw_cond.Width = 50
//Else
//	dw_cond.Width = 1746
//End If
//
//SetRedraw(True)
//
end event

type dw_cond from w_a_condition`dw_cond within b5w_1_reg_billing_receipt
integer width = 1746
string dataobject = "b5dw_1_file_reg_receipt_ae"
end type

event dw_cond::buttonclicked;CHOOSE CASE	dwo.Name
	CASE "search"	//파일찾기
		string pathName, fileName

		Int value

		value = GetFileOpenName("Select File", &
				+ pathName, fileName, "TXT", &
				+ "Text Files (*.TXT),*.TXT")

		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
	CASE "load"		//파일처리
		String 	ls_fileName
		Int		li_fileId
		
		ls_fileName = Trim(This.Object.filename[1])
		IF isNull(ls_fileName) THEN ls_fileName = ""
		
		IF ls_fileName = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		b5u_1_dbmgr lu_dbmgr
		lu_dbmgr = Create b5u_1_dbmgr
		
		lu_dbmgr.is_caller = "b5w_1_reg_billing_receipt"
		lu_dbmgr.is_Title = This.Title
		lu_dbmgr.is_data[1] = ls_fileName
		
		lu_dbmgr.uf_prc_db()
		
		If lu_dbmgr.ii_rc = -1 THen
			Destroy lu_dbmgr
			return
		Elseif lu_dbmgr.ii_rc = 0 then
			MessageBox("파일 처리 완료!! ","파일이름 ["+ ls_fileName + " ]의 처리가 완료되었습니다.")			

		End IF
				
		TriggerEvent('ue_open')
						
END CHOOSE
end event

type p_ok from w_a_condition`p_ok within b5w_1_reg_billing_receipt
boolean visible = false
integer x = 1897
end type

type p_close from w_a_condition`p_close within b5w_1_reg_billing_receipt
integer x = 1925
end type

type gb_cond from w_a_condition`gb_cond within b5w_1_reg_billing_receipt
integer width = 1797
end type

