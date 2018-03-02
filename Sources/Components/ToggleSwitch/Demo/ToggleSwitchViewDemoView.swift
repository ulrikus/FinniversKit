//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

public class ToggleSwitchViewDemoView: UIView {
    private lazy var recommendationsToggleSwitchView: ToggleSwitchView = {
        let toggleSwitchView = ToggleSwitchView()
        toggleSwitchView.translatesAutoresizingMaskIntoConstraints = false
        return toggleSwitchView
    }()

    private lazy var commercialToggleSwitchView: ToggleSwitchView = {
        let toggleSwitchView = ToggleSwitchView()
        toggleSwitchView.translatesAutoresizingMaskIntoConstraints = false
        return toggleSwitchView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setup() {
        recommendationsToggleSwitchView.model = ToggleSwitchDefaultData1()
        commercialToggleSwitchView.model = ToggleSwitchDefaultData2()

        addSubview(recommendationsToggleSwitchView)
        addSubview(commercialToggleSwitchView)

        NSLayoutConstraint.activate([
            recommendationsToggleSwitchView.topAnchor.constraint(equalTo: topAnchor),
            recommendationsToggleSwitchView.leadingAnchor.constraint(equalTo: leadingAnchor),
            recommendationsToggleSwitchView.trailingAnchor.constraint(equalTo: trailingAnchor),

            commercialToggleSwitchView.topAnchor.constraint(equalTo: recommendationsToggleSwitchView.bottomAnchor, constant: .mediumSpacing),
            commercialToggleSwitchView.leadingAnchor.constraint(equalTo: leadingAnchor),
            commercialToggleSwitchView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
