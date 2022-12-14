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
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Variables ***
${ORDERS_FILE_URL}      https://robotsparebinindustries.com/orders.csv
${ORDER_PAGE_URL}       https://robotsparebinindustries.com/#/robot-order

${receipt_folder}       ${OUTPUT_DIR}${/}receipts${/}
${screenshot_folder}    ${receipt_folder}screenshot${/}
${orders_file_name}     orders.csv


*** Tasks ***
Minimal task
    Log    Done.

Order robots from RobotSpareBin Industries Inc
    ${orders_file}=    Download order file
    Open the intranet website order site
    Fill form to order all the robots from the CSV file    ${orders_file}
    Create a ZIP file of the receipts


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
    [Arguments]    ${orders_file}
    # Download    ${ORDERS_FILE_URL}    overwrite=True
    # Download order file
    ${table}=    Read table from CSV    ${orders_file}    header=True
    FOR    ${row}    IN    @{table}
        Accept constitutional rights
        Fill one robot order form    ${row}[Head]    ${row}[Body]    ${row}[Legs]    ${row}[Address]
        Submit button to preview the robot

        Wait Until Keyword Succeeds    5x    1s    Submit The Order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the Robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Submit another robot order
    END

Store the receipt as a PDF file
    [Arguments]    ${pdf_file_name}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Set Local Variable    ${fqfn_pdf}    ${receipt_folder}${pdf_file_name}.pdf
    Html To Pdf    ${receipt_html}    ${fqfn_pdf}

    RETURN    ${fqfn_pdf}

Submit the order
    Click button    order
    Page Should Contain Element    id:receipt

Take a screenshot of the robot
    [Arguments]    ${image_file_name}
    Set Local Variable    ${id_robot_preview_image}    id:robot-preview-image
    Set Local Variable    ${fqfn_image}    ${screenshot_folder}${image_file_name}.jpg

    Wait Until Element Is Visible    ${id_robot_preview_image}
    Screenshot    ${id_robot_preview_image}    ${fqfn_image}
    # ${preview_robot_image_html}=    Get Element Attribute    ${id_robot_preview_image}    outerHTML
    RETURN    ${fqfn_image}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${fqfn_image}    ${fqfn_pdf}
    ${list}=    Create List    ${fqfn_image}:align=center
    Open Pdf    ${fqfn_pdf}
    Add Files To Pdf    ${list}    ${fqfn_pdf}    append=True
    Close pdf    ${fqfn_pdf}

Create a ZIP file of the receipts
    Archive Folder With Zip    ${receipt_folder}    ${receipt_folder}receips.zip    recursive=False

Submit button to preview the robot
    Click Button    preview

Submit another robot order
    Wait Until Keyword Succeeds    3x    1s    Click Button    order-another

Download order file
    [Documentation]    Downloads the file from the fixed URL.
    [Arguments]    ${timeout}=180    &{options}
    # Download    ${ORDERS_FILE_URL}    overwrite=True

    Add icon    warning
    Add heading    "hello, show the the url to the receipt files"
    Add text input    "URL to receipt file"
    ${url_to_receipt_file}=    Run dialog
    Log To Console    ${url_to_receipt_file}["URL to receipt file"]

    # be carefull with this, only works, because the file has the same name as expected.

    # Download    ${url_to_receipt_file}["URL to receipt file"]    overwrite=True    target_file=${orders_file_name}
    Download    ${ORDERS_FILE_URL}
    RETURN    ${orders_file_name}

Open the intranet website order site
    # Open Available Browser    ${ORDER_PAGE_URL}

    # to configure a secret needs to follow the instructions in https://robocorp.com/docs/development-guide/variables-and-secrets/vault
    # create vault.json somewhere (the vault)
    # create devdata/env.json, and set the key "RPA_SECRET_FILE": "path_to/vault.json"
    ${secret}=    Get Secret    credentials
    Open Available Browser    ${secret}[URL]
