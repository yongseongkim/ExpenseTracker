import ProjectDescription

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project(
    name: "ExpenseTracker",
    organizationName: "yongseongkim",
    targets: [
        Target(
            name: "ExpenseTracker",
            platform: .iOS,
            product: .app,
            bundleId: "dev.yongseongkim.ExpenseTracker",
            infoPlist: "ExpenseTracker/Info.plist",
            sources: ["ExpenseTracker/Sources/**"],
            resources: ["ExpenseTracker/Resources/**"],
            dependencies: [
            ],
            coreDataModels: [
                CoreDataModel(
                    .relativeToManifest("ExpenseTracker/CoreData/Model.xcdatamodeld"),
                    currentVersion: "Model"
                )
            ]
        ),
        Target(
            name: "ExpenseTrackerTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "dev.yongseongkim.ExpenseTrackerTests",
            infoPlist: "ExpenseTrackerTests/Info.plist",
            sources: ["ExpenseTrackerTests/Sources/ExpenseTrackerTests.swift"],
            dependencies: [
                .target(name: "ExpenseTracker")
            ]
        ),
        Target(
            name: "ExpenseTrackerUITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "dev.yongseongkim.ExpenseTrackerUITests",
            infoPlist: "ExpenseTrackerUITests/Info.plist",
            sources: ["ExpenseTrackerUITests/Sources/ExpenseTrackerUITests.swift"],
            dependencies: [
                .target(name: "ExpenseTracker")
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "ExpenseTracker",
            shared: true,
            buildAction: .buildAction(targets: ["ExpenseTracker"]),
            testAction: .targets(["ExpenseTrackerTests"]),
            runAction: .runAction(executable: "ExpenseTracker")
        )
    ],
    additionalFiles: [
    ]
)
