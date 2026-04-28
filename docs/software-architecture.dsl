workspace "Intiva" "Intiva Platform — Healthcare management system" {

    model {

        client = person "Client" \
            "A doctor, nurse, administrator, or relative who interacts with the platform."
            admin = person "Administration" "admin for platform" 

        cloudinary = softwareSystem "Cloudinary" \
            "Stores and delivers user and resident avatar images via CDN with on-the-fly transformation support." \
            "External"

        twilio = softwareSystem "Twilio" \
            "Delivers outbound SMS and email notifications to doctors, staff, administrators, and relatives." \
            "External"

        oauthProvider = softwareSystem "OAuth2 Provider" \
            "Handles federated authentication and issues JWT tokens via the OAuth2 / OpenID Connect protocol." \
            "External"

        intiva = softwareSystem "Intiva Platform" \
            "Centralised healthcare management platform for clinics and care facilities." {

            mobileApp = container "Mobile App" \
                "Cross-platform patient and staff-facing application." \
                "Flutter / Dart" \
                "MobileApp"

            backendApi = container "Backend API" \
                "Monolithic Spring Boot backend exposing a versioned REST API. Handles all business logic, authentication delegation, and integration with external services." \
                "Java 21 / Spring Boot 3" \
                "API"

            database = container "MongoDB Database" \
                "Document store for all structured domain data including users, residents, visits, and notifications." \
                "MongoDB 7" \
                "Database"
            
            webApp = container "Web application" "It allows the management of vehicle information"{
                
            }     
        }

        client -> intiva "Uses"

        intiva -> cloudinary  "Uploads and retrieves media assets" "HTTPS"
        intiva -> twilio      "Sends SMS and email notifications"  "HTTPS"
        intiva -> oauthProvider "Delegates authentication"        "HTTPS / OIDC"

        client     -> mobileApp  "Uses"                             "HTTPS"
        mobileApp  -> backendApi "Makes API calls to"              "REST / HTTPS"
        backendApi -> database   "Reads from and writes to"        "MongoDB Wire Protocol"
        admin -> webApp "Uses" "HTTPS"
        backendApi -> cloudinary    "Uploads and retrieves media"  "HTTPS"
        backendApi -> twilio        "Sends notifications via"      "HTTPS"
        backendApi -> oauthProvider "Validates tokens with"        "HTTPS / OIDC"
        webApp -> backendApi "Reads from and writes to " "REST/HTTPS"
    }

    views {

        systemContext intiva "SystemContext" {
            include *
            autoLayout lr
            title "Intiva Platform — System Context"
        }

        container intiva "Containers" {
            include *
            autoLayout lr
            title "Intiva Platform — Containers"
        }
        
        styles {
            element "Person" {
                shape Person
                background #1D9E75
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
                shape MobileDeviceLandscape
                background #1D9E75
                color #ffffff
            }
            element "API" {
                shape Hexagon
                background #534AB7
                color #ffffff
            }
        }
    }
}
