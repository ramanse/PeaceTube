#include "peacetubecontrol.h"
#include <QQmlEngine>

PeaceTubeControl::PeaceTubeControl(QQuickItem *parent) : QQuickWebView(parent)
{
    m_resultListModel = new ResultListModel();
    m_networkManger = new QNetworkAccessManager(this);
    if (m_networkManger) {
        connect(this, &PeaceTubeControl::composedTextChanged, [=] () {
            //HTTP Request
            if (m_networkManger) {
                if (m_searchResultList.count() > 0) {
                    m_searchResultList = QJsonArray();
                }
                if (m_composedText != "") {
                    QUrl url("https://www.googleapis.com/youtube/v3/search");
                    QUrlQuery query;
                    query.addQueryItem("part", "snippet");
                    query.addQueryItem("maxResults", "100");
                    query.addQueryItem("type","video");
                    query.addQueryItem("key","AIzaSyDDUomWkvfjCUeR21E9mxK8qOfYTJddVAo");
                    query.addQueryItem("videoEmbeddable","true");
                    query.addQueryItem("q",m_composedText);
                    url.setQuery(query.query());

                    QNetworkRequest request(url);
                    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
                    request.setAttribute(QNetworkRequest::User, QVariant(EnQuery::QUERY_SEARCH));
                    m_networkManger->get(request);
                }
            }
        });
        connect(this, &PeaceTubeControl::searchTextChanged, [=] () {
            //HTTP Request
            if (m_networkManger) {
                if (m_resultListModel && m_resultListModel->count() > 0) {
                    m_resultListModel->resetModel();
                }
                //https://clients1.google.com/complete/search?client=youtube&gs_ri=youtube&ds=yt&q=faded

                QUrl url("https://clients1.google.com/complete/search");
                QUrlQuery query;
                query.addQueryItem("client", "youtube");
                query.addQueryItem("gs_ri", "youtube");
                query.addQueryItem("ds","yt");
                query.addQueryItem("q",m_searchText);

                url.setQuery(query.query());

                QNetworkRequest request(url);
                qCritical()<<"URL is "<<url;
                request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
                request.setAttribute(QNetworkRequest::User, QVariant(EnQuery::QUERY_PREDICTION));
                m_networkManger->get(request);
            }
        });
        connect(m_networkManger, &QNetworkAccessManager::finished, [=](QNetworkReply* reply) {
            replyFinished(reply);

        });
        connect(m_resultListModel, &ResultListModel::partialListUpdated, [=]() {
            emit resultListModelChanged();
        });
    }
}

bool PeaceTubeControl::isAuthorized() const
{
    return m_isAuthorized;
}

ResultListModel *PeaceTubeControl::resultListModel() const
{
    return m_resultListModel;
}

QJsonArray PeaceTubeControl::searchResultList()
{
    return m_searchResultList;
}

QString PeaceTubeControl::predictionsList()
{
    return m_predictionsList;
}

void PeaceTubeControl::resetResultList()
{
    if (m_resultListModel && m_resultListModel->count() > 0) {
        m_resultListModel->resetModel();
    }
}

void PeaceTubeControl::replyFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::ServiceUnavailableError) {
        qCritical()<<"Something went wrong in the request";
    }
    else if (reply->error() == QNetworkReply::NoError && m_resultListModel) {

        auto requestType = reply->request().attribute(QNetworkRequest::User).toInt();
        switch (requestType) {
        case EnQuery::QUERY_PREDICTION: {
            QString strReply = static_cast<QString>(reply->readAll());
            QJsonDocument jsonResponse = QJsonDocument::fromJson(strReply.toUtf8());
            m_predictionsList = strReply;
            emit predictionsListChanged();
            //m_resultListModel->updateResultModel(resultJArray);
            //emit resultListModelChanged();
            //prepareVideoIdsRequest(resultJArray);
        }
        case EnQuery::QUERY_SEARCH: {
            qCritical()<<"Received Query search here";
            QString strReply = static_cast<QString>(reply->readAll());
            QJsonDocument jsonResponse = QJsonDocument::fromJson(strReply.toUtf8());
            m_searchResultList = jsonResponse.object().value("items").toArray();
            emit searchResultListChanged();
            //m_resultListModel->updateResultModel(resultJArray);
            //emit resultListModelChanged();
            //prepareVideoIdsRequest(resultJArray);
        }
            break;
        case EnQuery::QUERY_VIDEOS: {
            qCritical()<<"Received Query Videos here";
            QString strReply = static_cast<QString>(reply->readAll());
            QJsonDocument jsonResponse = QJsonDocument::fromJson(strReply.toUtf8());
            auto resultJArray = jsonResponse.object().value("items").toArray();
            m_resultListModel->updateVideoDetails(resultJArray);
            emit resultListModelChanged();
        }
            break;
        }



    }

}

void PeaceTubeControl::prepareVideoIdsRequest(QJsonArray &jArray)
{
    QUrl url("https://www.googleapis.com/youtube/v3/videos");
    QUrlQuery query;

    query.addQueryItem("part", "contentDetails,status");
    query.addQueryItem("key","AIzaSyDDUomWkvfjCUeR21E9mxK8qOfYTJddVAo");
    foreach (const QJsonValue & item, jArray) {
        query.addQueryItem("id",item.toObject().value("id").toObject().value("videoId").toString());

    }
    url.setQuery(query.query());
    qCritical()<<"URL is here "<<url;
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setAttribute(QNetworkRequest::User, QVariant(EnQuery::QUERY_VIDEOS));
    m_networkManger->get(request);
}

//https://youtube.googleapis.com/youtube/v3/videos?part=contentDetails&key=AIzaSyDDUomWkvfjCUeR21E9mxK8qOfYTJddVAo
ResultObject::ResultObject(const QJsonObject &jObject)
{
    setName(jObject.value("snippet").toObject().value("title").toString());
    setDescription(jObject.value("snippet").toObject().value("description").toString());
    setPreview(jObject.value("snippet").toObject().value("thumbnails").toObject().value("medium").toObject().value("url").toString());
    setVideoId(jObject.value("id").toObject().value("videoId").toString());

}

QString ResultObject::name() const
{
    return m_name;
}

void ResultObject::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString ResultObject::description() const
{
    return m_description;
}

void ResultObject::setDescription(const QString &description)
{
    if (m_description != description) {
        m_description = description;
        emit descriptionChanged();
    }
}

QString ResultObject::videoId() const
{
    return m_videoId;
}

void ResultObject::setVideoId(const QString &videoId)
{
    if (m_videoId != videoId) {
        m_videoId = videoId;
        emit videoIdChanged();
    }
}

QUrl ResultObject::preview() const
{
    return m_preview;
}

void ResultObject::setPreview(const QUrl &preview)
{
    if (m_preview != preview) {
        m_preview = preview;
        emit previewChanged();
    }

}

QString ResultObject::duration() const
{
    return m_duration;
}

void ResultObject::setDuration(const QString &duration)
{
    if (m_duration != duration) {
        m_duration = duration;
        emit durationChanged();
    }
}

void ResultListModel::addResult(ResultObject *mObject){
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    QQmlEngine::setObjectOwnership(mObject,  QQmlEngine::CppOwnership);
    mObject->setParent(this);
    m_inventoryObjs[mObject->videoId()] = mObject;
    if (rowCount() >= 10) {
        emit partialListUpdated();
    }
    endInsertRows();
}

ResultListModel::ResultListModel():
    QAbstractListModel (){

    connect(this, &ResultListModel::rowsInserted, this, [=]() {
        countChanged();
    });
    connect(this, &ResultListModel::rowsRemoved, this, [=]() {
        countChanged();
    });
}

ResultObject *ResultListModel::fetchResultAtIndex(qint16 index)
{
    if (index >= 0 && index <= m_inventoryObjs.count()) {
        auto object = m_inventoryObjs.begin() + index;
        return object.value();
    }
    return nullptr;
}

int ResultListModel::rowCount(const QModelIndex &parent) const{
    if (parent.isValid())
        return 0;
    return m_inventoryObjs.count();
}

QVariant ResultListModel::data(const QModelIndex &index, int role) const{
    if(index.row() < 0 || index.row() >= m_inventoryObjs.count())
        return  QVariant();

    ResultObject *resultObj = *(m_inventoryObjs.begin() + index.row());
    if (resultObj != nullptr) {
        switch (role) {
        case NameRole: return resultObj->name();
        case DescriptionRole: return resultObj->description();
        case PreviewRole: return resultObj->preview();
        case VideoIdRole: return resultObj->videoId();
        default: return  QVariant();
        }
    }
}

int ResultListModel::columnCount(const QModelIndex &) const
{
    return roleNames().size();
}

int ResultListModel::count() const
{
    return rowCount();
}

QHash<int, QByteArray> ResultListModel::roleNames() const{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[DescriptionRole] = "description";
    roles[PreviewRole] = "preview";
    roles[VideoIdRole] = "videoId";
    return roles;
}

void ResultListModel::resetModel()
{
    if (rowCount() > 0) {
        beginRemoveRows(QModelIndex(), 0, rowCount() - 1);
        qDeleteAll(m_inventoryObjs);
        m_inventoryObjs.clear();
        endRemoveRows();
    }

}

ResultObject *ResultListModel::getResultItemAt(qint16 &index)
{
    if (index >= 0 && index <= m_inventoryObjs.count()) {
        auto object = m_inventoryObjs.begin() + index;
        return object.value();
    }
    return nullptr;
}

void ResultListModel::updateResultModel(const QJsonArray &array)
{
    foreach (const QJsonValue & value, array) {
        QJsonObject obj = value.toObject();
        addResult(new ResultObject(obj));
    }
}

void ResultListModel::updateVideoDetails(const QJsonArray &array)
{
    foreach (const QJsonValue & value, array) {
        QJsonObject obj = value.toObject();
        QString videoId = obj.value("id").toString();
        auto rObj = m_inventoryObjs[videoId];
        rObj->setDuration(obj.value("contentDetails").toObject().value("duration").toString());
    }
}




