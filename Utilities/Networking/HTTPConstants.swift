// Copyright 2021-present Xsolla (USA), Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at q
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing and permissions and

import Foundation

public enum HTTPMethod: String
{
    case get  = "GET"
    case post = "POST"
    case put  = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

public enum HTTPHeaderKey
{
    public static let authorization = "Authorization"
    public static let accept = "Accept"
    public static let acceptCharset = "Accept-Charset"
    public static let acceptLanguage = "Accept-Language"
    public static let contentType = "Content-Type"
    public static let origin = "Origin"
    public static let cookie = "Cookie"
    public static let unauthorizedId = "x-unauthorized-id"
    public static let user = "x-user"
}

public enum HTTPCookieKey
{
    public static let locale = "locale"
}
