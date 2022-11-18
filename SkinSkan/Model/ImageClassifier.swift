//
//  ImageClassifier.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/22/22.
//

import Foundation
import Vision
import UIKit

/// ImageClassifier which contains a VNCoreMLModel used to implement the skin disease detection model into the app
class ImageClassifier {

    static func createImageClassifier() -> VNCoreMLModel {
        /// Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        /// Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? SkinSkanTest80(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        /// Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        /// Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    /// A common image classifier instance that all Image Predictor instances use to generate predictions.
    /// A VNCoreMLModel instance is only generated and is reused across the app
    /// Since each can be expensive in time and resources.
    private static let imageClassifier = createImageClassifier()

    /// The function signature the caller must provide as a completion handler.
    typealias ImagePredictionHandler = (_ predictions: [PredictionResult]?) -> Void

    /// A dictionary of prediction handler functions, each keyed by its Vision request.
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    /// Generates a new request instance that uses the Image Predictor's image classifier model.
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        
        /// Create an image classification request with an image classifier model.
        let imageClassificationRequest = VNCoreMLRequest(model: ImageClassifier.imageClassifier,
                                                         completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    /// Main function used to generate an image classification prediction for a photo.
    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }

        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        // Start the image classification request.
        try handler.perform(requests)
    }

    /// The completion handler method that Vision calls when it completes a request.
    ///  The method checks for errors and validates the request's results.
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        /// Remove the caller's handler from the dictionary and keep a reference to it.
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        /// Start with a `nil` value in case there's a problem.
        var predictions: [PredictionResult]? = nil

        /// Call the client's completion handler after the method returns.
        defer {
            /// Send the predictions back to the client.
            predictionHandler(predictions)
        }

        /// Check for an error first.
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        /// Check that the results aren't `nil`.
        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        /// Cast the request's results as an VNClassificationObservation array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            /// Image classifiers, like MobileNet, only produce classification observations.
            /// However, other Core ML model types can produce other observations.
            /// For example, a style transfer model produces `VNPixelBufferObservation` instances.
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        /// Create a prediction array from the observations.
        predictions = observations.map { observation in
            /// Convert each observation into an PredictionResult instance.
            PredictionResult(diseaseName: observation.identifier, confidencePct: Double(observation.confidence)*100)
        }
    }
}

extension CGImagePropertyOrientation {
    /// Converts an image orientation to a Core Graphics image property orientation.
    /// The two orientation types use different raw values.
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
            case .up: self = .up
            case .down: self = .down
            case .left: self = .left
            case .right: self = .right
            case .upMirrored: self = .upMirrored
            case .downMirrored: self = .downMirrored
            case .leftMirrored: self = .leftMirrored
            case .rightMirrored: self = .rightMirrored
            @unknown default: self = .up
        }
    }
}
