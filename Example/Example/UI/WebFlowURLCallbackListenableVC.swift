// XSOLLA_SDK_LICENCE_HEADER_PLACEHOLDER

import UIKit
import WebKit

public protocol WebFlowURLCallbackListenable: AnyObject
{
    func startFlow(with request: URLRequest, callbackUrl: URL, completion: @escaping (Result<URL, Error>) -> Void)
}

public protocol WebFlowURLCallbackListenableVCProtocol: UIViewController, WebFlowURLCallbackListenable
{

}

public class WebFlowURLCallbackListenableVC: UIViewController, WebFlowURLCallbackListenableVCProtocol
{
    private let webView = WKWebView(frame: .zero)
    private let dismissButton = UIButton(type: .system)

    public func configureWebView(configure: ((WKWebView) -> Void)?) { self._configureWebView = configure }
    public func configureDismissButton(configure: ((UIButton) -> Void)?) { self._configureDismissButton = configure }
    public func configureMainView(configure: ((UIView) -> Void)?) { self._configureMainView = configure }

    private var _configureWebView: ((WKWebView) -> Void)?
    private var _configureDismissButton: ((UIButton) -> Void)?
    private var _configureMainView: ((UIView) -> Void)?

    public var dismissRequestHandler: ((WebFlowURLCallbackListenableVC) -> Void)? =
    {
        controller in controller.dismiss(animated: true, completion: nil)
    }

    private var request: URLRequest?
    private var completion: ((Result<URL, Error>) -> Void)?
    private var callbackUrl: URL?
    private var processErrors = false

    public override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupWebView()
        setupDismissButton()

        _configureMainView?(view)
    }

    private func setupDismissButton()
    {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalTo: dismissButton.widthAnchor).isActive = true
        dismissButton.setTitle("╳", for: .normal)
        dismissButton.addTarget(self, action: #selector(onDismissButton(_:)), for: .touchUpInside)

        _configureDismissButton?(dismissButton)
    }

    private func setupWebView()
    {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        webView.navigationDelegate = self

        _configureWebView?(webView)
    }

    private func invalidateFlow()
    {
        processErrors = false

        webView.stopLoading()

        self.callbackUrl = nil
        self.completion = nil
        self.request = nil
    }

    @objc
    func onDismissButton(_ button: UIButton)
    {
        dismissRequestHandler?(self)
    }
}

extension WebFlowURLCallbackListenableVC: WebFlowURLCallbackListenable
{
    public func startFlow(with request: URLRequest,
                          callbackUrl: URL,
                          completion: @escaping (Result<URL, Error>) -> Void)
    {
        invalidateFlow()

        self.callbackUrl = callbackUrl
        self.completion = completion
        self.request = request

        processErrors = true
        webView.load(request)
    }
}

extension WebFlowURLCallbackListenableVC: WKNavigationDelegate
{
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let url = navigationAction.request.url,
              let callbackURLString = callbackUrl?.absoluteString,
              url.absoluteString.starts(with: callbackURLString)
        else
        {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        completion?(.success(url))

        invalidateFlow()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        guard processErrors else { return }

        completion?(.failure(error))
        invalidateFlow()
    }

    public func webView(_ webView: WKWebView,
                        didFailProvisionalNavigation navigation: WKNavigation!,
                        withError error: Error)
    {
        guard processErrors else { return }

        completion?(.failure(error))
        invalidateFlow()
    }
}
