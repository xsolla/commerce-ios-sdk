import UIKit

class PaystationLoadingView: UIView 
{
    private var activityIndicator: UIActivityIndicatorView!

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupActivityIndicator()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() 
    {
        activityIndicator = UIActivityIndicatorView()
        
        if #available(iOS 13.0, *)
        {
            backgroundColor = UIColor.systemBackground
            activityIndicator.style = .medium
        }
        else
        {
            backgroundColor = UIColor.systemBlue
            activityIndicator.style = .gray
        }

        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func toggleAnimation(_ animated: Bool)
    {
        if animated
        {
            self.activityIndicator.startAnimating()
        }
        else
        {
            self.activityIndicator.stopAnimating()
        }
    }
}
