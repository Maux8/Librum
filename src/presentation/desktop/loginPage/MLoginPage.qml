import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import CustomComponents
import Librum.style
import Librum.icons
import Librum.controllers
import Librum.models
import Librum.fonts

MFlickWrapper {
    id: root
    state: "start"
    states: [
        State {
            name: "start"
            PropertyChanges {
                target: passwordInput
                visible: false
            }
            PropertyChanges {
                target: optionsLayout
                visible: false
            }
            PropertyChanges {
                target: accountStorageText
                visible: false
            }
            PropertyChanges {
                target: nameInput
                visible: false
            }
            PropertyChanges {
                target: rememberMeCheckBox
                visible: false
            }
            PropertyChanges {
                target: acceptPolicy
                visible: false
            }
            PropertyChanges {
                target: loginButton
                visible: true
            }
            PropertyChanges {
                target: registerButton
                visible: false
            }
            PropertyChanges {
                target: registerLinkLabel
                visible: false
            }
            PropertyChanges {
                target: loginRedirecitonLinkArea
                visible: false
            }
        },
        State {
            name: "login"
            PropertyChanges {
                target: nameInput
                visible: false
            }
            PropertyChanges {
                target: passwordInput
                visible: true
            }
            PropertyChanges {
                target: optionsLayout
                visible: true
            }
            PropertyChanges {
                target: registerLinkLabel
                visible: true
            }
            PropertyChanges {
                target: loginText
                visible: true
            }
            PropertyChanges {
                target: accountStorageText
                visible: false
            }
            PropertyChanges {
                target: acceptPolicy
                visible: false
            }
            PropertyChanges {
                target: loginButton
                visible: true
            }
            PropertyChanges {
                target: registerButton
                visible: false
            }
            PropertyChanges {
                target: loginRedirecitonLinkArea
                visible: false
            }
        },
        State {
            name: "register"
            PropertyChanges {
                target: nameInput
                visible: true
            }
            PropertyChanges {
                target: passwordInput
                visible: true
            }
            PropertyChanges {
                target: loginText
                visible: false
            }
            PropertyChanges {
                target: accountStorageText
                visible: true
            }
            PropertyChanges {
                target: optionsLayout
                visible: false
            }
            PropertyChanges {
                target: acceptPolicy
                visible: true
            }
            PropertyChanges {
                target: loginButton
                visible: false
            }
            PropertyChanges {
                target: registerButton
                visible: true
            }
            PropertyChanges {
                target: registerLinkLabel
                visible: false
            }
            PropertyChanges {
                target: loginRedirecitonLinkArea
                visible: true
            }
        }
    ]
    contentHeight: Window.height < layout.implicitHe2ight ? layout.implicitHeight : Window.height

    // Passing the focus to emailInput on Component.onCompleted() causes it
    // to pass controll back to root for some reason, this fixes the focus problem.
    onActiveFocusChanged: if (activeFocus)
                              emailInput.giveFocus()

    Component.onCompleted: {
        // Focus the emailInput when page has loaded.
        emailInput.giveFocus()

        // For some reason this prevents a SEGV. Directly calling the auto login
        // directly causes the application to crash on startup.
        autoLoginTimer.start()

        // Determine the index of the language used in the combobox
        let index = languageComboBox.getIndexByText(AppInfoController.language)
        languageComboBox.defaultIndex = index
    }

    Timer {
        id: autoLoginTimer
        interval: 0
        onTriggered: AuthController.tryAutomaticLogin()
    }

    Shortcut {
        sequence: "Ctrl+Return"
        onActivated: internal.login()
    }

    Connections {
        id: proccessLoginResult
        target: AuthController
        function onLoginFinished(errorCode, message) {
            internal.processLoginResult(errorCode, message)
        }
    }

    Connections {
        id: authenticationControllerConnections
        target: AuthController

        function onRegistrationFinished(errorCode, message) {
            internal.proccessRegistrationResult(errorCode, message)
        }

        function onEmailConfirmationCheckFinished(confirmed) {
            internal.processEmailConfirmationResult(confirmed)
        }
    }

    Connections {
        id: proccessLoadingUserResult
        target: UserController
        function onFinishedLoadingUser(success) {
            if (success) {
                if (baseRoot.externalBookMode)
                    loadPage(externalReadingPage)
                else
                    loadPage(homePage, sidebar.homeItem, false)
            } else {
                loginFailedPopup.open()
            }

            loginButton.loading = false
        }
    }

    Page {
        id: page
        anchors.fill: parent
        bottomPadding: 22
        background: Rectangle {
            color: Style.colorAuthenticationPageBackground
        }

        MComboBox {
            id: languageComboBox
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 12
            width: 200
            height: 12
            dropDownIconLeft: true
            boxBackgroundColor: "transparent"
            checkBoxStyle: false
            fontSize: Fonts.size12
            selectedItemFontSize: Fonts.size12
            maxHeight: 200
            spacing: 14
            dropdownIconSize: 10
            popupSpacing: 14
            borderWidth: 0

            model: TranslationsModel

            onItemChanged: index => AppInfoController.switchToLanguage(
                               model.get(index).code)

            function getIndexByText(searchText) {
                for (var i = 0; i < model.count; ++i) {
                    if (model.get(i).text.toLocaleLowerCase(
                                ) === searchText.toLocaleLowerCase()) {
                        return i
                    }
                }

                return -1
            }
        }

        ColumnLayout {
            id: layout
            anchors.centerIn: parent
            width: 544

            Pane {
                id: backgroundRect
                Layout.fillWidth: true
                topPadding: 48
                horizontalPadding: 71
                bottomPadding: 42
                background: Rectangle {
                    color: Style.colorContainerBackground
                    radius: 5
                }

                ColumnLayout {
                    width: parent.width
                    spacing: 0

                    MLogo {
                        id: logo
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        id: welcomeText
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 24
                        text: qsTr("Welcome to Librum!")
                        color: Style.colorText
                        font.bold: true
                        font.pointSize: Fonts.size26
                    }

                    Label {
                        id: accountStorageText
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Your credentials are only used to authenticate yourself. Everything will be stored in a secure database.")
                        font.pointSize: Fonts.size13
                        color: Style.colorSubtitle
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: loginText
                        Layout.topMargin: 4
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Just enter your email ^^")
                        color: Style.colorSubtitle
                        font.pointSize: Fonts.size13
                    }

                    MLabeledInputBox {
                        id: emailInput
                        Layout.fillWidth: true
                        Layout.topMargin: 32
                        placeholderContent: "kaidoe@gmail.com"
                        placeholderColor: Style.colorPlaceholderText
                        headerText: qsTr("Email")

                        onEdited: internal.clearLoginError()
                        Keys.onPressed: event => {
                                            if (event.key === Qt.Key_Down
                                                || event.key === Qt.Key_Return) {
                                                passwordInput.giveFocus()
                                            }
                                        }
                    }

                    MLabeledInputBox {
                        id: nameInput
                        Layout.fillWidth: true
                        Layout.topMargin: 22
                        headerText: qsTr("Name")
                        placeholderContent: "Kai Doe"
                        placeholderColor: Style.colorPlaceholderText

                        onEdited: internal.clearLoginError()
                        Keys.onPressed: event => internal.moveFocusToNextInput(
                                            event, null, emailInput)
                    }

                    MLabeledInputBox {
                        id: passwordInput
                        Layout.fillWidth: true
                        Layout.topMargin: 22
                        headerText: qsTr("Password")
                        image: Icons.eyeOn
                        toggledImage: Icons.eyeOff

                        onEdited: internal.clearLoginError()
                        Keys.onPressed: event => {
                                            if (event.key === Qt.Key_Up) {
                                                emailInput.giveFocus()
                                            } else if (event.key === Qt.Key_Down
                                                       || event.key === Qt.Key_Return) {
                                                rememberMeCheckBox.giveFocus()
                                            }
                                        }
                    }

                    Label {
                        id: generalErrorText
                        Layout.topMargin: 8
                        visible: false
                        color: Style.colorErrorText
                    }

                    MAcceptPolicy {
                        id: acceptPolicy
                        Layout.fillWidth: true
                        Layout.topMargin: 24

                        onKeyUp: passwordInput.giveFocus()
                        onKeyDown: registerButton.giveFocus()
                    }
                    RowLayout {
                        id: optionsLayout
                        Layout.preferredWidth: parent.width
                        Layout.fillWidth: true
                        Layout.topMargin: 24

                        MCheckBox {
                            id: rememberMeCheckBox
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20

                            Keys.onPressed: event => {
                                                if (event.key === Qt.Key_Return) {
                                                    toggle()
                                                } else if (event.key === Qt.Key_Up) {
                                                    passwordInput.giveFocus()
                                                } else if (event.key === Qt.Key_Down) {
                                                    loginButton.giveFocus()
                                                }
                                            }
                        }

                        Label {
                            id: rememberMeText
                            text: qsTr("Remember me")
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 4
                            font.pointSize: Fonts.size11
                            color: Style.colorText

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: rememberMeCheckBox.toggle()
                            }
                        }

                        Item {
                            id: widthFiller
                            Layout.fillWidth: true
                        }

                        Label {
                            id: forgotPasswordLabel
                            text: qsTr("Forgot password?")
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 3
                            font.pointSize: Fonts.size10dot5
                            opacity: forgotPasswordPageRedirection.pressed ? 0.8 : 1
                            color: Style.colorBasePurple

                            MouseArea {
                                id: forgotPasswordPageRedirection
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: loadPage(forgotPasswordPage)
                            }
                        }
                    }

                    MButton {
                        id: loginButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        Layout.topMargin: 42
                        borderWidth: 0
                        backgroundColor: Style.colorBasePurple
                        fontSize: Fonts.size12
                        opacityOnPressed: 0.85
                        textColor: Style.colorFocusedButtonText
                        fontWeight: Font.Bold
                        text: qsTr("Login")

                        onClicked: internal.login()

                        onFocusChanged: {
                            if (focus)
                                opacity = opacityOnPressed
                            else
                                opacity = 1
                        }

                        Keys.onPressed: event => {
                                            if (event.key === Qt.Key_Up)
                                            rememberMeCheckBox.giveFocus()
                                            else if (event.key === Qt.Key_Return)
                                            internal.login()
                                        }
                    }

                    MButton {
                        id: registerButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        Layout.topMargin: 46
                        borderWidth: 0
                        backgroundColor: Style.colorBasePurple
                        fontSize: Fonts.size12
                        opacityOnPressed: 0.85
                        textColor: Style.colorFocusedButtonText
                        fontWeight: Font.Bold
                        text: qsTr("Let's start")

                        onClicked: internal.login()
                        onFocusChanged: {
                            if (focus)
                                opacity = opacityOnPressed
                            else
                                opacity = 1
                        }

                        Keys.onReturnPressed: internal.registerUser()
                        Keys.onUpPressed: acceptPolicy.giveFocus()
                    }
                }
            }

            Label {
                id: registerLinkLabel
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 14
                text: qsTr("Dou you want to create a new accoutn? Register")
                font.pointSize: Fonts.size10dot5
                opacity: registerLinkArea.pressed ? 0.8 : 1
                color: Style.colorBasePurple
                visible: false

                MouseArea {
                    id: registerLinkArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.state = "register"
                }
            }

            Label {
                id: loginRedirectionLabel
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 14
                text: qsTr("Already have an account with another Email? Login")
                font.pointSize: Fonts.size10dot5
                opacity: loginRedirecitonLinkArea.pressed ? 0.8 : 1
                color: Style.colorBasePurple

                MouseArea {
                    id: loginRedirecitonLinkArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.state = "login"
                }
            }
        }
    }

    MWarningPopup {
        id: loginFailedPopup
        x: Math.round(root.width / 2 - implicitWidth / 2)
        y: Math.round(root.height / 2 - implicitHeight / 2) - 75
        visible: false
        title: qsTr("We're Sorry")
        message: qsTr("Logging you in failed, please try again later.")
        leftButtonText: qsTr("Ok")
        rightButtonText: qsTr("Report")
        messageBottomSpacing: 8

        onDecisionMade: close()
        onOpenedChanged: if (opened)
                             loginFailedPopup.giveFocus()
    }

    QtObject {
        id: internal
        property color previousBorderColor: emailInput.borderColor

        function login() {
            if (root.state === "start") {
                loginButton.loading = true
                if (AuthController.checkIfEmailExists(emailInput.text)) {
                    root.state = "login"
                    loginButton.loading = false
                } else {
                    root.state = "register"
                    loginButton.loading = false
                }
            } else if (root.state === "login") {
                loginButton.loading = true
                AuthController.loginUser(emailInput.text, passwordInput.text,
                                         rememberMeCheckBox.checked)
                // root.state == register when button is pressed
            } else {
                loginButton.loading = true
                AuthController.registerUser(nameInput.text, emailInput.text,
                                            passwordInput.text,
                                            acceptPolicy.checked)
            }
        }

        function processLoginResult(errorCode, message) {
            if (errorCode === ErrorCode.NoError) {
                UserController.loadUser(rememberMeCheckBox.checked)
            } else if (errorCode !== ErrorCode.AutomaticLoginFailed) {
                internal.setLoginError(errorCode, message)
                loginButton.loading = false
            }
        }

        function proccessRegistrationResult(errorCode, message) {
            registerButton.loading = false

            if (errorCode === ErrorCode.NoError) {
                confirmEmailPopup.open()
                confirmEmailPopup.giveFocus()
            } else {
                internal.setRegistrationErrors(errorCode, message)
            }
        }

        function setLoginError(errorCode, message) {
            switch (errorCode) {
            case ErrorCode.EmailOrPasswordIsWrong:
                emailInput.setError()
                passwordInput.errorText = message
                passwordInput.setError()
                break
            case ErrorCode.EmailAddressTooLong:
                // Fall through
            case ErrorCode.EmailAddressTooShort:
                // Fall through
            case ErrorCode.InvalidEmailAddressFormat:
                emailInput.errorText = message
                emailInput.setError()
                break
            case ErrorCode.PasswordTooLong:
                // Fall through
            case ErrorCode.PasswordTooShort:

                passwordInput.errorText = message
                passwordInput.setError()
                break
            default:
                generalErrorText.text = message
                generalErrorText.visible = true
            }
        }

        function setRegistrationErrors(errorCode, message) {
            switch (errorCode) {
            case ErrorCode.UserWithEmailAlreadyExists:
                // Fall through
            case ErrorCode.InvalidEmailAddressFormat:
                // Fall through
            case ErrorCode.EmailAddressTooShort:
                // Fall through
            case ErrorCode.EmailAddressTooLong:
                // Fall through
                emailInput.errorText = message
                emailInput.setError()
                break
            case ErrorCode.PasswordTooShort:
                // Fall through
            case ErrorCode.PasswordTooLong:
                passwordInput.errorText = message
                passwordInput.setError()
                break
            case ErrorCode.NameTooShort:
                nameInput.errorText = message
                nameInput.setError()
                break
            case ErrorCode.NameTooLong:
                nameInput.errorText = message
                nameInput.setError()
                break
            default:
                generalErrorText.text = message
                generalErrorText.visible = true
            }
        }

        function clearLoginError() {
            emailInput.errorText = ""
            emailInput.clearError()
            passwordInput.errorText = ""
            passwordInput.clearError()

            generalErrorText.visible = false
            generalErrorText.text = ""
        }

        function policyIsAccepted() {
            if (acceptPolicy.activated)
                return true

            acceptPolicy.setError()
            return false
        }
    }
}
