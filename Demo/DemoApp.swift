import SwiftUI
import PostureContinuity
import PostureContinuityUI

/// The demo app owns two things the library deliberately does not decide:
///
/// 1. **The per-feature layout policy.** Which flows split, at what width,
///    and whether the column boundary follows the hinge is a product call.
///    `PostureContinuity` gives you the registry; the app fills it in.
/// 2. **The launch-argument harness.** `-posture-script "…"` lets a UI test,
///    a CI job or an agent driving the simulator push the app through a
///    deterministic posture sequence on launch.
@main
struct DemoApp: App {
    private let registry: LayoutPolicyRegistry
    private let launchScript: PostureScript?

    init() {
        // Checkout: two columns from 600 pt, but never across a horizontal
        // hinge, and with the boundary on a vertical one. The catalog would
        // register its own; a payment sheet would register `AlwaysSingleColumnPolicy`.
        var registry = LayoutPolicyRegistry(fallback: WidthThresholdPolicy(minimumWidthForTwoColumns: 600, sidebarFraction: 0.38))
        registry.register(
            HingeAvoidingPolicy(base: WidthThresholdPolicy(minimumWidthForTwoColumns: 600, sidebarFraction: 0.38)),
            for: PostureContinuitySimulation.checkoutFlow)
        self.registry = registry

        // Absent flag → nil → normal interactive launch. A malformed script is
        // reported by the view, never crashed on.
        switch PostureScript.fromLaunchArguments(CommandLine.arguments) {
        case .success(let script)?:
            self.launchScript = script
        case .failure?, nil:
            self.launchScript = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            PostureContinuityDemoView(registry: registry, launchScript: launchScript)
        }
    }
}
