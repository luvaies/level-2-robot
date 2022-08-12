*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...                 This Robot is made for loving you babe, to
...                 improve my automation skills with Robocorp.
...                 You could see the task in the following web:
...                 https://robocorp.com/docs/courses/build-a-robot

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Variables ***
${ORDERS_FILE_URL}      https://robotsparebinindustries.com/orders.csv
${ORDER_PAGE_URL}       https://robotsparebinindustries.com/#/robot-order

${receipt_folder}       receipt


*** Tasks ***
Minimal task
    Log    Done.

Order robots from RobotSpareBin Industries Inc
    Open the intranet website order site
    Fill form to order all the robots from the CSV file


*** Keywords ***
Accept constitutional rights
    Wait Until Element Is Visible    css:button.btn-dark
    Click Button    css:button.btn.btn-dark

Fill one robot order form
    [Arguments]    ${head}    ${body}    ${legs}    ${address}
    Select From List By Value    head    ${head}
    Select Radio Button    body    ${body}
    Input Text    xpath://input[@placeholder="Enter the part number for the legs"]    ${legs}    clear=True
    Input Text    address    ${address}

Fill form to order all the robots from the CSV file
    Download    ${ORDERS_FILE_URL}    overwrite=True
    ${table}=    Read table from CSV    orders.csv    header=True
    FOR    ${row}    IN    @{table}
        Accept constitutional rights
        Fill one robot order form    ${row}[Head]    ${row}[Body]    ${row}[Legs]    ${row}[Address]
        Submit button to preview the robot

        Wait Until Keyword Succeeds    5x    1s    Submit The Order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the Robot    ${row}[Order number]
        # Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Submit another robot order
    END

Store the receipt as a PDF file
    [Arguments]    ${pdf_file_name}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Set Local Variable    ${fqfn_pdf}    ${OUTPUT_DIR}${/}receipts${/}${pdf_file_name}.pdf
    Html To Pdf    ${receipt_html}    ${fqfn_pdf}

    RETURN    ${fqfn_pdf}

Submit the order
    # Wait Until Keyword Succeeds    20x    1.5s    Click button    order
    # IF    not    Page Should Contain Element    id:receipt
    # Click button    order
    # #Do not generate screenshots if the test fails
    # Mute Run On Failure    Page Should Contain Element

    # Submit the order. If we have a receipt, then all is well
    Click button    order
    Page Should Contain Element    id:receipt

Take a screenshot of the robot
    [Arguments]    ${image_file_name}
    ${preview_robot_image_html}=    Get Element Attribute    id:robot-preview-image    outerHTML

Submit button to preview the robot
    Click Button    preview

Submit another robot order
    Wait Until Keyword Succeeds    3x    1s    Click Button    order-another

Download order file
    [Documentation]    Downloads the file from the fixed URL.
    Download    ${ORDERS_FILE_URL}    overwrite=True

Open the intranet website order site
    Open Available Browser    ${ORDER_PAGE_URL}
