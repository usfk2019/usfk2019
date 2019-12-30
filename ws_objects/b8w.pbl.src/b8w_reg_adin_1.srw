$PBExportHeader$b8w_reg_adin_1.srw
$PBExportComments$[kem]  입고등록 - mac addr 포함
forward
global type b8w_reg_adin_1 from w_a_reg_m_m
end type
type dw_file from datawindow within b8w_reg_adin_1
end type
end forward

global type b8w_reg_adin_1 from w_a_reg_m_m
integer width = 3547
integer height = 2024
dw_file dw_file
end type
global b8w_reg_adin_1 b8w_reg_adin_1

forward prototypes
public subroutine of_resizepanels ()
end prototypes

public subroutine of_resizepanels ();dw_detail.Width = 1850
end subroutine

on b8w_reg_adin_1.create
int iCurrent
call super::create
this.dw_file=create dw_file
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
end on

on b8w_reg_adin_1.destroy
call super::destroy
destroy(this.dw_file)
end on

event open;call super::open;dw_master.Object.idate[1] = fdt_get_dbserver_now()

dw_file.Enabled = False

end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
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

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event ue_delete;call super::ue_delete;Long ll_row
Long ll_cnt

ll_row = dw_detail.getRow()

IF(ll_row > 1 ) THEN

	dw_detail.DeleteRow(ll_row)
	
	FOR ll_cnt=ll_row to dw_detail.rowCount()
		dw_detail.Object.num[ll_cnt] = dw_detail.Object.num[ll_cnt] -1
	Next
	
	dw_master.Object.iqty[1] = dw_detail.rowCount()

END IF

Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
Long		ll_adseq		//장비번호
String	ls_serialno	//Serial No.
String	ls_adtype	//장비구분
String	ls_modelno 	//모델번호
String	ls_status	//재고상태
String	ls_adstat	//장비상태
Long		ll_iseqno	//입고번호
String	ls_makercd	//제조사번호
DATETIME	ld_idate		//입고일자
String	ls_mv_partner //이동대리점
Long		ll_idamt		//입고단가
String	ls_entstore //입고처
String	ls_remark	//비고
String   ls_macaddr  //mac address
	
String 	ls_action	//장비이력현황 action
Long 		ll_seq		//장비이력현황 seq
	
ls_makercd 	= Trim(dw_master.Object.makercd[1])							//제조사번호
ld_idate		= dw_master.Object.idate[1]									//입고일자
ll_idamt		= dw_master.Object.idamt[1]									//입고단가
ls_entstore = Trim(dw_master.Object.entstore[1])						//입고처
ls_remark	= Trim(dw_master.Object.remark[1])							//비고
	
	
//모델번호
ls_modelno = Trim(dw_master.Object.modelno[1])

//재고상태
SELECT ref_content INTO :ls_status FROM sysctl1t 
WHERE module = 'E1' AND ref_no = 'A100';

//장비상태
SELECT ref_content INTO :ls_adstat FROM sysctl1t 
WHERE module = 'E1' AND ref_no = 'A200';

//장비구분
SELECT adtype  INTO :ls_adtype FROM admodel
WHERE modelno = :ls_modelno;


//이동대리점
SELECT ref_content INTO :ls_mv_partner FROM sysctl1t 
WHERE module = 'A1' AND ref_no = 'C102';

//필수항목 Check
ll_rows	= dw_detail.RowCount()

//dw_master의 입고수량을 실제 입력된 row수로 정정한다.
dw_master.Object.iqty[1] = ll_rows

FOR ll_rowcnt=1 TO ll_rows
	ls_serialno	= Trim(dw_detail.Object.serialno[ll_rowcnt])
	IF IsNull(ls_serialno) THEN ls_serialno = ""
	
	//Serial No. 체크
	IF ls_serialno = "" THEN
		f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 Serial No.")
		dw_detail.setColumn("serialno")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//Serial No. 중복체크 - 안하기로 정함
	//2003.12.10 중복체크 로직 다시 설정.
	Int li_cnt
	
	SELECT count(*)
	INTO :li_cnt
	FROM admst
	WHERE serialno = :ls_serialno
	AND   modelno  = :ls_modelno ;
	
	IF li_cnt > 0 THEN
		f_msg_usr_err(201, Title, String(ll_rowcnt) + "번 Serial No.[" + ls_serialno + "]는 이미 저장된 번호입니다.")
		dw_detail.setColumn("serialno")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	
		//장비번호
		ll_adseq = dw_detail.Object.adseq[ll_rowcnt]										//장비번호	
		
		
		//기타정보 입력
		dw_detail.Object.adtype[ll_rowcnt]		= ls_adtype								//장비구분
		dw_detail.Object.dan_yn[ll_rowcnt]		= 'Y'										//단품여부
		dw_detail.Object.makercd[ll_rowcnt] 	= ls_makercd							//제조사번호
		dw_detail.Object.modelno[ll_rowcnt] 	= ls_modelno							//모델번호
		dw_detail.Object.status[ll_rowcnt]		= ls_status								//재고상태
		dw_detail.Object.use_yn[ll_rowcnt]		= 'Y'										//사용가능여부
		dw_detail.Object.adstat[ll_rowcnt]		= ls_adstat								//장비상태
		dw_detail.Object.idate[ll_rowcnt]		= ld_idate								//입고일자
		dw_detail.Object.iseqno[ll_rowcnt]		= ll_iseqno								//입고번호
		dw_detail.Object.mv_partner[ll_rowcnt]	= ls_mv_partner						//이동대리점
		dw_detail.Object.idamt[ll_rowcnt]		= ll_idamt								//입고단가
		dw_detail.Object.sale_flag[ll_rowcnt]	= '0'										//판매임대구분
		dw_detail.Object.entstore[ll_rowcnt]	= ls_entstore							//입고처
		dw_detail.Object.remark[ll_rowcnt]		= ls_remark								//비고
		
		dw_detail.Object.crt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.crtdt[ll_rowcnt]		= fdt_get_dbserver_now()
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
		dw_detail.Object.pgm_id[ll_rowcnt]		= gs_pgm_id[gi_open_win_no]
		
		
		//장비이력(admstlog) Table에 정보저장
		//일련번호(seq)추출
		SELECT seq_admstlog.nextval 		INTO :ll_seq		FROM dual;
		
		//행위(action)추출
		SELECT ref_content 		INTO :ls_action		FROM sysctl1t 
		WHERE module = 'E1' AND ref_no = 'A300';
	
		//실제입력시간
		Datetime now
		now = fdt_get_dbserver_now()
		
		//장비이력(admstlog)에 Insert	
		INSERT INTO admstlog
		(adseq,seq,action,status,actdt,to_partner,crt_user,crtdt,pgm_id)
		VALUES(:ll_adseq,:ll_seq,:ls_action,:ls_status,:ld_idate,:ls_mv_partner,:gs_user_id,:now,:gs_pgm_id[gi_open_win_no]);
NEXT

//No Error
RETURN 0
end event

event ue_insert;Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)

//장비번호
//새 장비번호 추출
Long ll_adseq			//새 장비번호

	SELECT seq_adseq.nextval
	INTO :ll_adseq
	FROM dual;

dw_detail.Object.adseq[ll_row]	= ll_adseq								//장비번호	
		
dw_detail.Object.num[ll_row] = ll_row

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

dw_master.Object.iqty[1] = ll_row

Return 0

end event

event ue_ok;call super::ue_ok;long ll_cnt

//### 입고정보
String ls_modelno, ls_makercd, ls_entstore
String ls_idate
Long	 ll_iqty, ll_idamt, ll_inamt, ll_invat
String ls_ret_yn, ls_remark

If dw_master.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망
	dw_master.SetFocus()
	Return
End If

ls_modelno = Trim(dw_master.Object.modelno[1])
ls_makercd = Trim(dw_master.Object.makercd[1])
ls_idate = Trim(String(dw_master.Object.idate[1],'yyyymmdd'))
ls_entstore = Trim(dw_master.Object.entstore[1])
ll_iqty = dw_master.Object.iqty[1]
ll_idamt = dw_master.Object.idamt[1]
ll_inamt = dw_master.Object.inamt[1]
ll_invat = dw_master.Object.invat[1]
ls_ret_yn = Trim(dw_master.Object.ret_yn[1])
ls_remark = Trim(dw_master.Object.remark[1])


//### 필수데이터 체크

//제조사
IF IsNull(ls_makercd) THEN
	f_msg_usr_err(200, Title, "제조사")
	dw_master.setColumn("makercd")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//모델명
IF IsNull(ls_modelno) THEN
	f_msg_usr_err(200, Title, "모델명")
	dw_master.setColumn("modelno")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//입고일자
IF IsNull(ls_idate) or ls_idate = "" THEN
	f_msg_usr_err(200, Title, "입고일자")
	dw_master.setColumn("idate")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//입고처
IF IsNull(ls_entstore) THEN
	f_msg_usr_err(200, Title, "입고처")
	dw_master.setColumn("entstore")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//입고단가
IF IsNull(ll_idamt) THEN
	f_msg_usr_err(200, Title, "입고단가")
	dw_master.setColumn("idamt")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//입고수량
IF IsNull(ll_iqty) THEN
	f_msg_usr_err(200, Title, "입고수량")
	dw_master.setColumn("iqty")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//공급가액
IF IsNull(ll_inamt) THEN
	f_msg_usr_err(200, Title, "공급가액")
	dw_master.setColumn("inamt")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//부가세
IF IsNull(ll_invat) THEN
	f_msg_usr_err(200, Title, "부가세")
	dw_master.setColumn("invat")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF


//### 입고거래 기타정보 입력
//입고자
dw_master.Object.iman[1] = gs_user_id

//Log 정보
dw_master.Object.crt_user[1] 	= gs_user_id
dw_master.Object.crtdt[1] 		= fdt_get_dbserver_now()
dw_master.Object.updt_user[1] = gs_user_id
dw_master.Object.updtdt[1]		= fdt_get_dbserver_now()
dw_master.Object.pgm_id[1]		= gs_pgm_id[gi_open_win_no]


//### 장비마스터 정보 입력
Long ll_detailRow //dw_detail의 row수
ll_detailRow = dw_detail.rowCount()


Long ll_adseq			//새 장비번호

//dw_detail의 row 수 > 입고정보에 입력된 입고수량
IF( ll_detailRow > ll_iqty ) THEN
	FOR ll_cnt=ll_iqty+1 TO ll_detailRow
		dw_detail.deleteRow(ll_iqty+1)	//수량차이 만큼 dw_detail에 Row삭제
	Next
ELSEIF( ll_detailRow < ll_iqty ) THEN
	FOR ll_cnt=ll_detailRow+1 TO ll_iqty
		dw_detail.insertRow(ll_cnt)	//수량차이 만큼 dw_detail에 Row추가
		//장비번호
		//새 장비번호 추출
			SELECT seq_adseq.nextval
			INTO :ll_adseq
			FROM dual;

		dw_detail.Object.adseq[ll_cnt]	= ll_adseq								//장비번호	

		dw_detail.Object.num[ll_cnt]	= ll_cnt
	Next
END IF

//File DW 활성화
dw_file.Enabled = True
dw_detail.Enabled = True

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

end event

event ue_reset;call super::ue_reset;p_ok.TriggerEvent("ue_enable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = False
dw_detail.reset()

dw_master.Enabled = True
dw_master.reset()
dw_master.insertRow(1)
dw_master.Object.idate[1] = fdt_get_dbserver_now()
dw_master.Object.modelno.Protect = True

dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = False
RETURN 0

end event

event type integer ue_save();Constant Int LI_ERROR = -1

Long result

//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if


If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
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
End if



//새 입고번호
Long ll_iseqno

SELECT seq_adinseq.nextval INTO :ll_iseqno FROM dual;


//새 입고번호 dw_master에 입력
dw_master.Object.iseqno[1] = ll_iseqno

//새 입고번호 dw_detail에 입력
Long ll_cnt
FOR ll_cnt = 1 TO dw_detail.rowCount()
	dw_detail.Object.iseqno[ll_cnt] = ll_iseqno
NEXT


If (dw_master.Update() < 0) or (dw_detail.Update() < 0) then
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
	
	//모델(admodel) Table에 입고장비 수 만큼 재고수량(stockqty) 추가
	Long 		ll_iqty
	String	ls_modelno
	
	ll_iqty = dw_detail.rowCount()
	ls_modelno = Trim(dw_master.Object.modelno[1])
	
	UPDATE admodel
	   SET stockqty = stockqty + :ll_iqty
	 WHERE modelno = :ls_modelno;
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End if

//저장완료
//TriggerEvent("ue_reset")
p_ok.TriggerEvent("ue_disable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")

dw_master.Enabled 	= False
dw_file.Enabled 		= False
dw_detail.Enabled 	= False

//ii_error_chk = 0
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b8w_reg_adin_1
boolean visible = false
end type

type p_ok from w_a_reg_m_m`p_ok within b8w_reg_adin_1
integer x = 3168
integer y = 68
end type

type p_close from w_a_reg_m_m`p_close within b8w_reg_adin_1
integer x = 3168
integer y = 188
end type

type gb_cond from w_a_reg_m_m`gb_cond within b8w_reg_adin_1
boolean visible = false
end type

type dw_master from w_a_reg_m_m`dw_master within b8w_reg_adin_1
event ue_cal ( )
integer x = 23
integer y = 24
integer width = 3035
integer height = 704
string dataobject = "b8dw_reg_adindtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_master::ue_cal;//공급가액과 부가세를 계산해주는 Event
this.AcceptText()

IF (not IsNull(THIS.Object.iqty[1])) AND (not IsNull(THIS.Object.idamt[1])) THEN
			THIS.Object.inamt[1]	= THIS.Object.iqty[1] * THIS.Object.idamt[1]	//공급가액
			THIS.Object.invat[1]	= Round(THIS.Object.inamt[1] *0.1,0)			//부가세
END IF
end event

event dw_master::clicked;//상속막음
end event

event dw_master::itemchanged;call super::itemchanged;This.AcceptText()

CHOOSE CASE UPPER(dwo.Name)
	CASE "IDAMT"
		TriggerEvent("ue_cal")

	CASE "IQTY"
		TriggerEvent("ue_cal")
		
	CASE "MAKERCD"
		//제조사에 해당하는 모델만 보여주기..
		DataWindowChild ldc
		String ls_filter
		Long ll_row
		ll_row = This.GetChild("modelno", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "makercd = '" + This.Object.makercd[1] + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve() 
	
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
		This.Object.modelno.Protect = False
		
	CASE "MODELNO"
		//제조사에 해당하는 모델만 보여주기..
		IF( IsNull(This.Object.makercd[1]) OR This.Object.makercd[1] = "") THEN
			f_msg_usr_err(200, Title, "제조사")
			//This.Object.modelno[1] = ""
			
			This.setColumn("makercd")
			This.setRow(1)
			This.setFocus()	
		END IF
		
END CHOOSE

end event

type dw_detail from w_a_reg_m_m`dw_detail within b8w_reg_adin_1
integer x = 23
integer y = 768
integer width = 1856
integer height = 940
string dataobject = "b8dw_reg_admst_1"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b8w_reg_adin_1
integer y = 1752
end type

type p_delete from w_a_reg_m_m`p_delete within b8w_reg_adin_1
integer y = 1756
end type

type p_save from w_a_reg_m_m`p_save within b8w_reg_adin_1
integer y = 1756
end type

type p_reset from w_a_reg_m_m`p_reset within b8w_reg_adin_1
integer y = 1756
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b8w_reg_adin_1
integer x = 37
string text = " "
end type

type dw_file from datawindow within b8w_reg_adin_1
integer x = 1915
integer y = 768
integer width = 1522
integer height = 256
integer taborder = 50
boolean bringtotop = true
string title = "none"
string dataobject = "b8dw_file_reg_adin"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event buttonclicked;call super::buttonclicked;CHOOSE CASE	dwo.Name
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
		
		li_fileId = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기
		
		If(IsNull(li_fileId) or li_fileId < 0) THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If
		
		String	ls_fileRow			//파일내용이 한줄 저장되는 변수
		String	ls_fileRow1			//Serial No
		String	ls_fileRow2			//Mac Address
		Long		ll_fileRows = 0	//파일의 row수가 저장되는 변수
		Long		ll_iqty				//현재 입고예정인 row수
		Long 		ll_adseq				//새 장비번호
		Long		ll_row				//새로 입력된 row
		Int		li_location			//Text가공시 필요한 위치정보
		Int		li_location1		//Text가공시 필요한 위치정보
		
		ll_iqty = dw_detail.rowCount()
		
		//End of File(return -100)을 만날때까지 파일을 한줄씩 읽는다.
		DO UNTIL( FileRead(li_fileId,ls_fileRow) = -100 )
			
			IF(ls_fileRow <> "") THEN
			
				ll_fileRows++
				
				IF( ll_iqty < ll_fileRows) THEN //입고예정 수량보다 파일row수가 많은 경우
					ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)
	
					//장비번호
					//새 장비번호 추출
						SELECT seq_adinseq.nextval
						INTO :ll_adseq
						FROM dual;
					
					dw_detail.Object.adseq[ll_row]	= ll_adseq								//장비번호	
							
					dw_detail.Object.num[ll_row] = ll_row
					
					dw_master.Object.iqty[1] = ll_row
				END IF
				
				//ls_fileRow에 저장된 시리얼넘버를 얻어온다.
				li_location = PosA(ls_fileRow,"~t") //첫번째 ","
				li_location1 = li_location+1      //두번째 ","
//				li_location	= Pos(ls_fileRow,",",li_location+1) //세번째 ","
//				li_location	= Pos(ls_fileRow,",",li_location+1) //네번째 ","
				
				//추출된 시리얼넘버
				ls_fileRow = TRIM(ls_fileRow)
				ls_fileRow1 = TRIM(MidA(ls_fileRow, 1, li_location - 1))
				ls_fileRow2 = TRIM(MidA(ls_fileRow, li_location1, (LenA(ls_filerow) - li_location)))
				
				IF(ls_fileRow <> "") THEN
					dw_detail.Object.serialno[ll_fileRows] = ls_fileRow1
					dw_detail.Object.spec_item1[ll_fileRows] = ls_fileRow2
				END IF
			END IF	
		LOOP
		
		FileClose(li_fileId) //파일닫기
		
		//입력예정인 수량보다 파일에서 읽은 시리얼넘버가 작을 경우 경고
		IF(dw_detail.rowcount() > ll_fileRows) THEN
			MessageBox("Serial No.부족","입고수량보다 파일로 입력된 Serial No.수량이 적습니다.")
			ll_fileRows++
		END IF
		
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_fileRows)
		dw_detail.SetRow(ll_fileRows)
		dw_detail.SetFocus()
						
END CHOOSE
end event

event constructor;InsertRow(0)
end event

