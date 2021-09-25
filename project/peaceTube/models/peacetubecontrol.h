#ifndef PEACETUBECONTROL_H
#define PEACETUBECONTROL_H

#include <QtWebView>
#include <QtWebView/private/qquickwebview_p.h>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QUrlQuery>
#include <QNetworkReply>

class ResultObject : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QUrl preview READ preview WRITE setPreview NOTIFY previewChanged)
    Q_PROPERTY(QString videoId READ videoId WRITE setVideoId NOTIFY videoIdChanged)
    Q_PROPERTY(QString duration READ duration WRITE setDuration NOTIFY durationChanged)

public:
    ResultObject(const QJsonObject &jObject);

    QString name() const;
    void setName(const QString &name);
    QString description() const;
    void setDescription(const QString &description);
    QString videoId() const;
    void setVideoId(const QString &videoId);
    QUrl preview() const;
    void setPreview(const QUrl &preview);

    QString duration() const;
    void setDuration(const QString &duration);

signals:
    void nameChanged();
    void descriptionChanged();
    void previewChanged();
    void videoIdChanged();
    void durationChanged();

private:
    QString m_name;
    QString m_description;
    QString m_videoId;
    QString m_duration;
    QUrl m_preview;
};


class ResultListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_ENUMS(ResultListRoles)
public:
    ResultListModel();
    Q_INVOKABLE ResultObject *fetchResultAtIndex(qint16 index);


    enum ResultListRoles{
        NameRole = Qt::UserRole +1,
        DescriptionRole,
        PreviewRole,
        VideoIdRole
    };

    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
    int columnCount(const QModelIndex & = QModelIndex()) const override;
    int count() const;
    void resetModel();
    ResultObject *getResultItemAt(qint16 &index);
    void addResult(ResultObject *mObject);
    void updateResultModel(const QJsonArray &array);
    void updateVideoDetails(const QJsonArray &array);
signals:
    void countChanged();
    void partialListUpdated();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:


    QHash<QString, ResultObject *> m_inventoryObjs;
};


class PeaceTubeControl : public QQuickWebView
{
    Q_OBJECT

    Q_PROPERTY(QString composedText MEMBER m_composedText NOTIFY composedTextChanged)
    Q_PROPERTY(QString searchText MEMBER m_searchText NOTIFY searchTextChanged)
    Q_PROPERTY(bool isAuthorized READ isAuthorized NOTIFY isAuthorizedChanged)
    Q_PROPERTY(ResultListModel *resultListModel READ resultListModel NOTIFY resultListModelChanged)
    Q_PROPERTY(QJsonArray searchResultList READ searchResultList NOTIFY searchResultListChanged)
    Q_PROPERTY(QString predictionsList READ predictionsList NOTIFY predictionsListChanged)

public:
    PeaceTubeControl(QQuickItem *parent = 0);
    bool isAuthorized() const;
    ResultListModel *resultListModel() const;
    QJsonArray searchResultList();
    QString predictionsList();
    Q_INVOKABLE void resetResultList();
signals:
    void composedTextChanged();
    void searchTextChanged();
    void isAuthorizedChanged();
    void resultListModelChanged();
    void searchResultListChanged();
    void predictionsListChanged();
private:
    enum EnQuery
    {
        QUERY_PREDICTION,
        QUERY_SEARCH,
        QUERY_VIDEOS
    };
    QString m_searchText{""};
    QString m_composedText{""};
    bool m_isAuthorized{true}; //until oAuth is implemented
    ResultListModel *m_resultListModel;
    QJsonArray m_searchResultList;
    QString m_predictionsList;

    //For http queries
    QNetworkAccessManager *m_networkManger;
    void replyFinished(QNetworkReply *reply);
    void prepareVideoIdsRequest( QJsonArray&);

};

#endif // PEACETUBECONTROL_H
