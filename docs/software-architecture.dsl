workspace "Intiva" "Intiva Platform — Vehicle Loans Simulator" {

    model {
        client = person "Client" \
            "Person that seeks information about vehicle loans (bank, efective rate)."

        admin = person "Administration" \
            "Company worker that manages the vehicle and loans information."

        cloudinary = softwareSystem "Cloudinary" \
            "Stores and delivers user and resident avatar images via CDN with on-the-fly transformation support." \
            "External"

        twilio = softwareSystem "Twilio" \
            "Delivers outbound email notifications to clients with its simulations." \
            "External"

        oauth2 = softwareSystem "OAuth2" \
            "Handles federated authentication and issues JWT tokens via the OAuth2 / OpenID Connect protocol." \
            "External"

        intiva = softwareSystem "Intiva Platform" \
            "Centralised healthcare management platform for clinics and care facilities." {

            mobileApp = container "Intiva Mobile Application" \
                "Cross-platform application for vehicle loans simulation." \
                "Dart, Flutter" \
                "MobileApp" {
                mobileIamContext = component "IAM UI" \
                    "Displays the sign-in and sign-up forms." \
                    "Dart, Flutter"

                mobileProfilesContext = component "Profiles UI" \
                    "Displays user's personal information." \
                    "Dart, Flutter"

                mobileVehiclesContext = component "Vehicles UI" \
                    "Displays available vehicles for possible simulations." \
                    "Dart, Flutter"

                mobileAnalyticsContext = component "Analytics UI" \
                    "Displays simulation form and simulation results." \
                    "Dart, Flutter"

                mobileShared = component "Shared" \
                    "Handles common utilities and widgets across the contexts." \
                    "Dart, Flutter"
            }

            backendApi = container "Intiva Cloud API" \
                "Monolithic API exposing a versioned REST API. Also handles all business logic, authentication delegation, and integration with external services." \
                "Java 21, Spring Boot 3" \
                "API" {
                apiCommunicationContext = component "Communication" \
                    "Manages notifications of loans simulations." \
                    "Java 21, Spring Boot 3"

                apiIamContext = component "Identity and Access Management" \
                    "Manages user authentication and authorization." \
                    "Java 21, Spring Boot 3"

                apiProfilesContext = component "Profiles and Preferences" \
                    "Manages personal information and preferences." \
                    "Java 21, Spring Boot 3"

                apiVehiclesContext = component "Vehicle Management" \
                    "Manages vehicle information and registration for loan simulations." \
                    "Java 21, Spring Boot 3"

                apiAnalyticsContext = component "Analytics" \
                    "Manages vehicle loan simulation operations." \
                    "Java 21, Spring Boot 3"

                apiShared = component "Shared" \
                    "Handles common infrastructure, implementations and value objects across the contexts." \
                    "Java 21, Spring Boot 3"
            }

            database = container "Intiva MongoDB Database" \
                "Document store for all structured domain data including users, residents, visits, and notifications." \
                "MongoDB 7" \
                "Database"

            localDatabase = container "Mobile SQLite Database" \
                "Stores app data locally on the mobile device." \
                "SQLite" \
                "Database"

            webApplication = container "Web Application" \
                "Serves the platform's web application content." \
                "JavaScript, React.js" {
                staticContent = component "Static Content" "Serves React PWA files." "JavaScript, React.js"
            }

            frontendApp = container "Frontend Application" \
                "Allows the management of vehicle information" \
                "JavaScript, React.js" "Frontend" {
                frontIamContext = component "IAM UI" \
                    "Displays the sign-in and sign-up forms." \
                    "JavaScript, React.js"

                frontProfilesContext = component "Profiles UI" \
                    "Displays user's personal information." \
                    "JavaScript, React.js"

                frontVehiclesContext = component "Vehicles UI" \
                    "Displays available vehicles and allows registration of new vehicles." \
                    "JavaScript, React.js"

                frontShared = component "Shared" \
                    "Handles common utilities and components across the contexts." \
                    "JavaScript, React.js"
            }
        }

        client         -> intiva         "Simulates vehicle loans"
        client         -> mobileApp      "Simulates vehicle loans"
        admin          -> webApplication "Visits Intiva using"                        "HTTPS"
        admin          -> staticContent  "Visits Intiva using"                        "HTTPS"
        admin          -> intiva         "Manages vehicle and loans information"
        admin          -> frontendApp    "Manages vehicle and loan information"       "HTTPS"
        intiva         -> cloudinary     "Uploads and retrieves media assets"         "HTTPS"
        intiva         -> twilio         "Sends SMS and email notifications"          "HTTPS"
        intiva         -> oauth2         "Delegates authentication"                   "HTTPS/OIDC"
        mobileApp      -> backendApi     "Reads from and writes loan simulation data" "JSON/HTTPS"
        mobileApp      -> localDatabase  "Caches and retrieves simulation data"
        backendApi     -> database       "Reads from and writes to"                   "MongoDB Wire Protocol"
        backendApi     -> cloudinary     "Uploads and retrieves media"                "HTTPS"
        backendApi     -> twilio         "Sends notifications via"                    "HTTPS"
        backendApi     -> oauth2         "Validates tokens with"                      "HTTPS/OIDC"
        frontendApp    -> backendApi     "Reads from and writes loan management data" "JSON/HTTPS"
        webApplication -> frontendApp    "Delivers content to the user's web browser"
        staticContent  -> frontendApp    "Delivers content to the user's web browser" "HTTPS"

        apiIamContext           -> oauth2        "Requests authorization from Google"  "HTTPS"
        apiIamContext           -> apiShared     "Uses shared utilities"
        apiIamContext           -> database      "Stores user data"                    "MongoDB Wire Protocol"
        apiVehiclesContext      -> cloudinary    "Uploads and retrieves vehicle media" "JSON/HTTPS"
        apiVehiclesContext      -> apiIamContext "Verifies JWT and ensures the roles of the user"
        apiVehiclesContext      -> database      "Stores vehicle data"                 "MongoDB Wire Protocol"
        apiVehiclesContext      -> apiShared     "Uses shared utilities"
        apiCommunicationContext -> twilio        "Sends notifications via"             "HTTPS"
        apiProfilesContext      -> database      "Stores user's personal data"         "MongoDB Wire Protocol"
        apiProfilesContext      -> apiIamContext "Verifies JWT"
        apiProfilesContext      -> apiShared     "Uses shared utilities"
        apiAnalyticsContext     -> database      "Stores loan simulation data"         "MongoDB Wire Protocol"
        apiAnalyticsContext     -> apiIamContext "Verifies JWT"
        apiAnalyticsContext     -> apiCommunicationContext "Sends data to report to the user email" "ACL"
        apiAnalyticsContext     -> apiShared     "Uses shared utilities"

        mobileIamContext        -> backendApi    "Authenticates mobile users"              "JSON/HTTPS"
        mobileIamContext        -> mobileShared  "Extends base api and endpoint and widget utilities"
        mobileIamContext        -> oauth2        "Redirects to authorization page from Google"      "HTTPS"
        mobileProfilesContext   -> backendApi    "Requests personal information"           "JSON/HTTPS"
        mobileProfilesContext   -> mobileShared  "Extends base api and endpoint and widget utilities"
        mobileVehiclesContext   -> backendApi    "Requests available vehicles to simulate" "JSON/HTTPS"
        mobileVehiclesContext   -> mobileShared  "Extends base api and endpoint and widget utilities"
        mobileAnalyticsContext  -> backendApi    "Requests and registers loan simulation data" "JSON/HTTPS"
        mobileAnalyticsContext  -> mobileShared  "Extends base api and endpoint and widget utilities"
        mobileAnalyticsContext  -> localDatabase "Caches registered loan simulations"

        frontIamContext        -> backendApi    "Authenticates admin users"              "JSON/HTTPS"
        frontIamContext        -> frontShared   "Extends base api and endpoint and components"
        frontIamContext        -> oauth2        "Redirects to authorization page from Google"      "HTTPS"
        frontProfilesContext   -> backendApi    "Requests personal information"           "JSON/HTTPS"
        frontProfilesContext   -> frontShared   "Extends base api and endpoint and components"
        frontVehiclesContext   -> backendApi    "Requests and registers vehicles"         "JSON/HTTPS"
        frontVehiclesContext   -> frontShared   "Extends base api and endpoint and components"
    }

    views {

        systemContext intiva "SystemContext" {
            include *
            autoLayout lr
            title "Intiva Platform — Software Architecture Context Diagram"
        }

        container intiva "Containers" {
            include *
            autoLayout lr
            title "Intiva Platform — Software Architecture Container Diagram"
        }

        component mobileApp "MobileComponent" {
            include *
            autoLayout lr
            title "Intiva Platform — Software Architecture Mobile App Component Diagram"
        }

        component webApplication "WebAppComponent" {
            include *
            autoLayout lr
            title "Intiva Platform — Software Architecture Web App Component Diagram"
        }

        component frontendApp "FrontendAppComponent" {
            include *
            autoLayout lr
            title "Intiva Platform — Software Architecture Frontend App Component Diagram"
        }

        component backendApi "CloudAPIComponent" {
            include *
            autoLayout lr
            title "Intiva Platform — Software Architecture Cloud API Component Diagram"
        }

        styles {
            element "Person" {
                shape Person
                background #1f4e79
                color #ffffff
            }
            element "Software System" {
                background #7F77DD
                color #ffffff
            }
            element "External" {
                background #888780
                color #ffffff
            }
            element "Frontend" {
                shape "WebBrowser"
            }
            element "Container" {
                background #534AB7
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #BA7517
                color #ffffff
            }
            element "MobileApp" {
                shape MobileDevicePortrait
                background #1D9E75
                color #ffffff
            }
            element "API" {
                shape Box
                background #2B14FA
                color #ffffff
            }
        }
    }
}