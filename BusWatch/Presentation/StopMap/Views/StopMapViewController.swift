//
//  StopMapViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import MapKit
import Combine

final class StopMapViewController: UIViewController {

    // MARK: - Views

    private let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Map"
        label.textColor = .white
        return label
    }()

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    private lazy var fabButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = style.locationButtonColor
        button.layer.cornerRadius = 35
        button.tintColor = .white
        button.setImage(UIImage(systemName: "location"), for: .normal)
        // Must set the background color for the image to be centered. Not really sure why...
        button.imageView?.backgroundColor = .clear
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        let buttonSize = CGSize(width: button.layer.cornerRadius * 2.0, height: button.layer.cornerRadius * 2.0)
        let imageSize = CGSize(width: 30, height: 30)
        let leftRightInset = (buttonSize.width - imageSize.width) / 2.0
        let topBottomInset = (buttonSize.height - imageSize.height) / 2
        button.imageEdgeInsets = UIEdgeInsets(
            top: topBottomInset,
            left: leftRightInset,
            bottom: topBottomInset,
            right: leftRightInset
        )
        button.addTarget(self, action: #selector(handleFabButtonTouch(sender:)), for: UIControl.Event.touchUpInside)
        return button
    }()

    // MARK: - Properties

    private let viewModel: StopMapViewModel

    private let style: StopMapStyle

    private var cancellables = Set<AnyCancellable>()

    private var currentStopAnnotations: [StopMapStopAnnotation]?

    private var fabWidthConstraint: NSLayoutConstraint?

    private var fabButtonCornerRadius: CGFloat {
        return fabButton.layer.cornerRadius
    }

    // MARK: - Initialization

    init(viewModel: StopMapViewModel, style: StopMapStyle) {
        self.viewModel = viewModel
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("StopMapViewController Error: View Controller be cannot initialized with init(coder:)")
    }

    deinit {
        cancellables.removeAll()
        mapView.removeAllAnnotations()
        mapView.delegate = nil
        print("Deinniting StopMapViewController")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupSubviews()
        setupObservers()
    }

    // MARK: - Setup

    private func setupViewController() {
        title = ""
        navigationItem.titleView = titleView
    }

    private func setupSubviews() {
        view.addSubview(mapView)
        view.addSubview(fabButton)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let fabWidthConstraint = fabButton.widthAnchor.constraint(equalToConstant: fabButton.layer.cornerRadius * 2)
        NSLayoutConstraint.activate([
            fabWidthConstraint,
            fabButton.heightAnchor.constraint(equalToConstant: fabWidthConstraint.constant),
            fabButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            fabButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        self.fabWidthConstraint = fabWidthConstraint
    }

    private func setupMapView() {
        mapView.register(MKPinAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.delegate = self
    }

    private func setupObservers() {
        viewModel.state.sink { [weak self] state in
            switch state {
            case .setLocationBounds(let locationBounds):
                // We setup the map view here to avoid the mapView regionDidChangeAnimated on the default map location
                self?.setupMapView()
                self?.renderSetLocationBoundsState(locationBounds)
            case .setLocationBoundsWithStops(let locationBounds, let stops):
                self?.renderSetLocationBoundsWithStopsState(locationBounds, stops: stops)
            case .error(let message):
                self?.renderErrorState(message)
            default:
                break
            }
        }
        .store(in: &cancellables)

        viewModel.fabState.sink { [unowned self] show in
            self.mapView.showsUserLocation = show
            self.fabWidthConstraint?.constant = show ? self.fabButton.layer.cornerRadius * 2 : 0
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 5,
                           options: .curveEaseInOut,
                           animations: {
                self.fabButton.layoutIfNeeded()
            })
        }
        .store(in: &cancellables)
    }

    // MARK: - Button handling

    @objc private func handleFabButtonTouch(sender: Any) {
        mapView.animateToUserLocation()
    }

    // MARK: - State Rendering

    private func renderSetLocationBoundsState(_ locationBounds: LocationBounds) {
        if locationBounds != mapView.locationBounds {
            mapView.setLocationBounds(locationBounds, animated: false)
        }
    }

    private func renderSetLocationBoundsWithStopsState(_ locationBounds: LocationBounds, stops: [DetailedStop]) {
        if locationBounds != mapView.locationBounds {
            // Only update the map location if it's not already set there.
            // This will trigger mapView regionDidChangeAnimated
            mapView.setLocationBounds(locationBounds, animated: false)
        }

        let newStopAnnotations = stops.map { stop in StopMapStopAnnotation(stop: stop) }

        guard let currentStopAnnotations = self.currentStopAnnotations else {
            self.currentStopAnnotations = newStopAnnotations
            mapView.addAnnotations(newStopAnnotations)
            return
        }

        var stopAnnotationsToAdd = [StopMapStopAnnotation]()
        var stopAnnotationsToRemove = [StopMapStopAnnotation]()

        let diffs = newStopAnnotations.difference(from: currentStopAnnotations)
        for update in diffs {
            switch update {
            case .remove(_, let element, let move):
                // If there's no move, it's a removal
                if move == nil {
                    stopAnnotationsToRemove.append(element)
                }
            case .insert(_, let element, let move):
                // If there's no move, it's an insertion
                if move == nil {
                    stopAnnotationsToAdd.append(element)
                }
            }
        }

        self.currentStopAnnotations = currentStopAnnotations.applying(diffs)!

        mapView.addAnnotations(stopAnnotationsToAdd)
        mapView.removeAnnotations(stopAnnotationsToRemove)
    }

    private func renderErrorState(_ message: String) {
        print(message)
    }
}

// MARK: - MKMapViewDelegate

extension StopMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewModel.handleIntent(.mapLocationMoved(mapView.locationBounds))
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        view?.isEnabled = true
        view?.canShowCallout = true
        view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view?.rightCalloutAccessoryView?.tintColor = style.mapAnnotationTintColor
        return view
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? StopMapStopAnnotation else { return }
        viewModel.handleIntent(.stopSelected(annotation.stop))
    }
}
